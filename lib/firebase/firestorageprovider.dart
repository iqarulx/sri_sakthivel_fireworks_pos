import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FireStorageProvider {
  final storage = FirebaseStorage.instance.ref();

  Future<String?> uploadImage({
    required File fileData,
    required String fileName,
    required String filePath,
  }) async {
    String? downloadLink;
    final uploadDir = storage.child("$filePath/$fileName");
    try {
      await uploadDir.putFile(fileData);
      downloadLink = await uploadDir.getDownloadURL();
    } catch (e) {
      log(e.toString());
    }
    return downloadLink;
  }
}
