import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p; 

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload foto profil
  static Future<String> uploadProfilePhoto(String uid, String filePath) async {
    final String ext = p.extension(filePath); 
    final ref = _storage.ref('profiles/$uid/foto_profil$ext');
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }

  /// Upload gambar produk
  static Future<String> uploadProductImage(String uid, String filePath) async {
    final String ext = p.extension(filePath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    final ref = _storage.ref('produk/$uid/$timestamp$ext');
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }
}