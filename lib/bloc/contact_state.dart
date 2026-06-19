import '../models/contact.dart';

abstract class ContactState {}

class ContactLoading extends ContactState {}

class ContactLoaded extends ContactState {
  final List<Contact> contacts;
  ContactLoaded(this.contacts);

  List<Contact> get favorites =>
      contacts.where((c) => c.isFavorite).toList();
}

class ContactError extends ContactState {
  final String message;
  ContactError(this.message);
}
