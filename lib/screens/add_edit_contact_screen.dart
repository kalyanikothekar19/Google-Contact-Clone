import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/contact_bloc.dart';
import '../bloc/contact_event.dart';
import '../bloc/contact_state.dart';
import '../models/contact.dart';
import '../widgets/contact_avatar.dart';
import 'package:flutter/services.dart';

class AddEditContactScreen extends StatefulWidget {
  final Contact? contact;
  const AddEditContactScreen({super.key, this.contact});

  @override
  State<AddEditContactScreen> createState() => _AddEditContactScreenState();
}

class _AddEditContactScreenState extends State<AddEditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController emailCtrl;
  String? photoPath;
  File? pickedImageFile;
  bool isSaving = false;

  bool get isEditing => widget.contact != null;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.contact?.name ?? '');
    phoneCtrl = TextEditingController(text: widget.contact?.phone ?? '');
    emailCtrl = TextEditingController(text: widget.contact?.email ?? '');
    photoPath = widget.contact?.photoPath;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () async {
                final img = await picker.pickImage(source: ImageSource.camera);
                Navigator.pop(ctx, img);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                final img = await picker.pickImage(source: ImageSource.gallery);
                Navigator.pop(ctx, img);
              },
            ),
          ],
        ),
      ),
    );

    if (picked != null) {
      setState(() {
        pickedImageFile = File(picked.path);
      });
    }
  }

  Future<void> saveContact() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isSaving = true);

    try {
      if (isEditing) {
        final updated = widget.contact!;
        updated.name = nameCtrl.text.trim();
        updated.phone = phoneCtrl.text.trim();
        updated.email = emailCtrl.text.trim();

        context.read<ContactBloc>().add(
              UpdateContact(updated, photoFile: pickedImageFile),
            );
      } else {
        context.read<ContactBloc>().add(
              AddContact(
                Contact(
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                ),
                photoFile: pickedImageFile,
              ),
            );
      }

      await Future.delayed(Duration.zero); // let bloc event register
      if (mounted) {
        final bloc = context.read<ContactBloc>();
        await bloc.stream.firstWhere((state) => state is ContactLoaded);
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save contact: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Contact' : 'New Contact'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: isSaving ? null : saveContact,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: Stack(
                  children: [
                    pickedImageFile != null
                        ? CircleAvatar(
                            radius: 50,
                            backgroundImage: FileImage(pickedImageFile!),
                          )
                        : ContactAvatar(
                            name: nameCtrl.text.isEmpty ? '?' : nameCtrl.text,
                            photoPath: photoPath,
                            radius: 50,
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: const Icon(Icons.camera_alt,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: nameCtrl,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Name is required';
                  }
                  if (val.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(val.trim())) {
                    return 'Name can only contain letters and spaces';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneCtrl,
                maxLength: 10,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(val.trim())) {
                    return 'Enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty)
                    return null; // email is optional
                  if (!RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$')
                      .hasMatch(val.trim())) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : saveContact,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isEditing ? 'Save Changes' : 'Add Contact'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
