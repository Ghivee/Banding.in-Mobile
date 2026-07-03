import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
// USER PROFILE
static Stream<DocumentSnapshot> streamUserData(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  static Future<void> updateUserPhoto(String uid, String url) async {
    await _db.collection('users').doc(uid).set({'fotoProfilUrl': url}, SetOptions(merge: true)).timeout(
      const Duration(seconds: 10),
      onTimeout: () {},
    );
  }
// TOKO
static Stream<QuerySnapshot> streamToko(String uid) {
    return _db
        .collection('toko')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> addToko(String uid, String namaToko, String logoUrl) async {
    await _db.collection('toko').add({
      'uid': uid,
      'namaToko': namaToko,
      'logoUrl': logoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    }).timeout(const Duration(seconds: 10));
  }

  static Future<void> deleteToko(String docId) async {
    await _db.collection('toko').doc(docId).delete().timeout(
      const Duration(seconds: 10),
    );
  }
// PRODUK TERSIMPAN
static Stream<QuerySnapshot> streamProdukTersimpan(String uid) {
    return _db
        .collection('produkTersimpan')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> addProduk({
    required String uid,
    required String namaProduk,
    required String namaToko,
    required int diskon,
    required int harga,
    required int hargaAkhir,
    required String gambarUrl,
  }) async {
    await _db.collection('produkTersimpan').add({
      'uid': uid,
      'namaProduk': namaProduk,
      'namaToko': namaToko,
      'diskon': diskon,
      'harga': harga,
      'hargaAkhir': hargaAkhir,
      'gambarUrl': gambarUrl,
      'createdAt': FieldValue.serverTimestamp(),
    }).timeout(const Duration(seconds: 10));
  }

  static Future<void> deleteProduk(String docId) async {
    await _db.collection('produkTersimpan').doc(docId).delete().timeout(
      const Duration(seconds: 10),
    );
  }
}
