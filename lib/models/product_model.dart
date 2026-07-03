import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String uid;
  final String namaProduk;
  final String namaToko;
  final int diskon;
  final int harga;
  final int hargaAkhir;
  final String gambarUrl;

  ProductModel({
    required this.id,
    required this.uid,
    required this.namaProduk,
    this.namaToko = 'BANDING.IN',
    this.diskon = 0,
    required this.harga,
    required this.hargaAkhir,
    this.gambarUrl = '',
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      namaProduk: data['namaProduk'] ?? '',
      namaToko: data['namaToko'] ?? 'BANDING.IN',
      diskon: (data['diskon'] ?? 0).toInt(),
      harga: (data['harga'] ?? 0).toInt(),
      hargaAkhir: (data['hargaAkhir'] ?? 0).toInt(),
      gambarUrl: data['gambarUrl'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'namaProduk': namaProduk,
        'namaToko': namaToko,
        'diskon': diskon,
        'harga': harga,
        'hargaAkhir': hargaAkhir,
        'gambarUrl': gambarUrl,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
