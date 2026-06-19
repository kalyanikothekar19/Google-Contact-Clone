import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/contact_repository.dart';
import '../repository/storage_helper.dart';
import 'contact_event.dart';
import 'contact_state.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final ContactRepository repo = ContactRepository();
  final StorageHelper storageHelper = StorageHelper();

  ContactBloc() : super(ContactLoading()) {
    on<LoadContacts>((event, emit) async {
      emit(ContactLoading());
      try {
        final contacts = await repo.getContacts();
        emit(ContactLoaded(contacts));
      } catch (e) {
        emit(ContactError('Could not load contacts'));
      }
    });

    on<AddContact>((event, emit) async {
      try {
        final newId = await repo.insertContact(event.contact);

        if (event.photoFile != null) {
          final localPath = await storageHelper.uploadPhoto(
            event.photoFile!,
            newId,
          );
          event.contact.id = newId;
          event.contact.photoPath = localPath;
          await repo.updateContact(event.contact);
        }

        final contacts = await repo.getContacts();
        emit(ContactLoaded(contacts));
      } catch (e) {
        emit(ContactError(e.toString()));
      }
    });

    on<UpdateContact>((event, emit) async {
      try {
        if (event.photoFile != null) {
          final localPath = await storageHelper.uploadPhoto(
            event.photoFile!,
            event.contact.id!,
          );
          event.contact.photoPath = localPath;
        }

        await repo.updateContact(event.contact);
        final contacts = await repo.getContacts();
        emit(ContactLoaded(contacts));
      } catch (e) {
        emit(ContactError(e.toString()));
      }
    });

    on<DeleteContact>((event, emit) async {
      try {
        await storageHelper.deletePhoto(event.contactId);
        await repo.deleteContact(event.contactId);
        final contacts = await repo.getContacts();
        emit(ContactLoaded(contacts));
      } catch (e) {
        emit(ContactError(e.toString()));
      }
    });
    on<ToggleFavorite>((event, emit) async {
      event.contact.isFavorite = !event.contact.isFavorite;
      await repo.updateContact(event.contact);
      final contacts = await repo.getContacts();
      emit(ContactLoaded(contacts));
    });
  }
}
