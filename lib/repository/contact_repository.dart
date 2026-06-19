import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contact.dart';

class ContactRepository {
  final CollectionReference _contactsRef =
      FirebaseFirestore.instance.collection('contacts');

  Future<List<Contact>> getContacts() async {
    final snapshot = await _contactsRef.orderBy('name').get();
    return snapshot.docs
        .map((doc) => Contact.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<String> insertContact(Contact contact) async {
    final docRef = await _contactsRef.add(contact.toMap());
    return docRef.id;
  }

  Future<void> updateContact(Contact contact) async {
    await _contactsRef.doc(contact.id).update(contact.toMap());
  }

  Future<void> deleteContact(String id) async {
    await _contactsRef.doc(id).delete();
  }
}
