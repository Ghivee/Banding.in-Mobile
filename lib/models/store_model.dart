import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModel {
  final String id;
  final String uid;
  final String namaToko;
  final String logoUrl;

  StoreModel({
    required this.id,
    required this.uid,
    required this.namaToko,
    this.logoUrl = '',
  });

  factory StoreModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoreModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      namaToko: data['namaToko'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'namaToko': namaToko,
        'logoUrl': logoUrl,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
