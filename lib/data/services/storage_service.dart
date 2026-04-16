import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;

  Future<String> subirFotoProgreso(String uid, String rutaLocal) async {
    final file = File(rutaLocal);
    final nombre = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('progress_photos/$uid/$nombre');
    final task = await ref.putFile(file);
    return await task.ref.getDownloadURL();
  }

  Future<void> eliminarFoto(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint('StorageService: error eliminando foto: $e');
    }
  }
}
