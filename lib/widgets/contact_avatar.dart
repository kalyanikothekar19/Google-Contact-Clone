import 'package:flutter/material.dart';
import 'dart:io';

class ContactAvatar extends StatelessWidget {
  final String name;
  final String? photoPath;
  final double radius;

  const ContactAvatar({
    super.key,
    required this.name,
    this.photoPath,
    this.radius = 24,
  });

  String get initials {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (photoPath != null && photoPath!.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.deepPurple.shade100,
        backgroundImage: NetworkImage(photoPath!),
      );
    }
    if (photoPath != null && File(photoPath!).existsSync()) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.deepPurple.shade100,
        backgroundImage: FileImage(File(photoPath!)),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.deepPurple.shade300,
      child: Text(
        initials,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
