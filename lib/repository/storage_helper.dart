import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StorageHelper {
  Future<String> uploadPhoto(File file, String contactId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final contactPhotosDir = Directory(p.join(appDir.path, 'contact_photos'));

    if (!await contactPhotosDir.exists()) {
      await contactPhotosDir.create(recursive: true);
    }

    final fileName = 'contact_$contactId.jpg';
    final savedFile = await file.copy(
      p.join(contactPhotosDir.path, fileName),
    );

    return savedFile.path;
  }

  Future<void> deletePhoto(String contactId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final filePath = p.join(
      appDir.path,
      'contact_photos',
      'contact_$contactId.jpg',
    );

    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
