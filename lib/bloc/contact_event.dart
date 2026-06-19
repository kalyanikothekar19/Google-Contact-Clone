import 'dart:io';
import '../models/contact.dart';

abstract class ContactEvent {}

class LoadContacts extends ContactEvent {}

class AddContact extends ContactEvent {
  final Contact contact;
  final File? photoFile;
  AddContact(this.contact, {this.photoFile});
}

class UpdateContact extends ContactEvent {
  final Contact contact;
  final File? photoFile;
  UpdateContact(this.contact, {this.photoFile});
}

class DeleteContact extends ContactEvent {
  final String contactId;
  DeleteContact(this.contactId);
}

class ToggleFavorite extends ContactEvent {
  final Contact contact;
  ToggleFavorite(this.contact);
}
