import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static String? get currentUid => _auth.currentUser?.uid;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> register(
    String nama,
    String email,
    String password,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    // Simpan profil ke Firestore dengan timeout
    try {
      await _db
          .collection('users')
          .doc(cred.user!.uid)
          .set({
            'nama': nama.trim(),
            'email': email.trim(),
            'fotoProfilUrl': '',
          })
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              // Data akan ter-sync otomatis saat online
            },
          );
    } catch (_) {
      // Jangan gagalkan registrasi hanya karena Firestore error
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  static Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
