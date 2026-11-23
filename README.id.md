# Banding.in

Aplikasi Flutter untuk membandingkan harga barang bekas antar mahasiswa: katalog, filter, chat, dan riwayat, dibangun di atas Firebase.

[English](README.md)

## Teknologi

Flutter, Firebase (Auth, Cloud Firestore, Storage), `image_picker`, `cached_network_image`.

## Menjalankan

```bash
flutter pub get
```

Siapkan proyek Firebase dan tambahkan `google-services.json` (Android) dan `GoogleService-Info.plist` (iOS) milik sendiri; keduanya tidak disertakan di repositori ini. Aturan keamanan Firestore ada di `firestore.rules`, aturan storage di `storage.rules`.

```bash
flutter run
```

## Struktur

```
lib/screens/    login, register, layar utama
lib/tabs/       tab perbandingan, dashboard, profil
lib/services/   akses Firebase
lib/models/     model data
```
