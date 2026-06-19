import 'package:MyContacts/bloc/contact_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/contact_bloc.dart';
import '../bloc/contact_event.dart';
import '../models/contact.dart';
import '../widgets/contact_avatar.dart';
import '../widgets/delete_dialog.dart';
import 'add_edit_contact_screen.dart';

class ContactProfileScreen extends StatelessWidget {
  final Contact contact;

  const ContactProfileScreen({super.key, required this.contact});

  Future<void> callNumber(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not place call')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactBloc, ContactState>(
      builder: (context, state) {
        Contact currentContact = contact;

        if (state is ContactLoaded) {
          final index = state.contacts.indexWhere((c) => c.id == contact.id);
          if (index != -1) {
            currentContact = state.contacts[index];
          }
        }

        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon: Icon(
                  currentContact.isFavorite ? Icons.star : Icons.star_border,
                  color: currentContact.isFavorite ? Colors.amber : Colors.grey,
                ),
                onPressed: () {
                  context
                      .read<ContactBloc>()
                      .add(ToggleFavorite(currentContact));
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            AddEditContactScreen(contact: currentContact)),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirmed = await showDeleteConfirmation(
                      context, currentContact.name);
                  if (confirmed) {
                    if (context.mounted) {
                      context
                          .read<ContactBloc>()
                          .add(DeleteContact(currentContact.id!));
                      Navigator.pop(context);
                    }
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ContactAvatar(
                    name: currentContact.name,
                    photoPath: currentContact.photoPath,
                    radius: 60),
                const SizedBox(height: 16),
                Text(currentContact.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.phone, color: Colors.green),
                    title: Text(currentContact.phone),
                    subtitle: const Text('Mobile'),
                    trailing: IconButton(
                      icon: const Icon(Icons.call, color: Colors.green),
                      onPressed: () =>
                          callNumber(context, currentContact.phone),
                    ),
                  ),
                ),
                if (currentContact.email.isNotEmpty)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.email, color: Colors.blue),
                      title: Text(currentContact.email),
                      subtitle: const Text('Email'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
