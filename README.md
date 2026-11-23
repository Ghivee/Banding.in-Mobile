# Banding.in

Banding.in ("comparing" in Indonesian) is a Flutter app for university students to compare secondhand item prices against other students on their own campus, the same "trade only within a trusted circle" idea as BBB.id but aimed at price comparison rather than a full marketplace flow. A student lists an item with a price, browses what others have listed, filters results, and can chat with a seller before deciding whether a price is fair, with the full history kept for reference.

[Baca dalam Bahasa Indonesia di bawah](#bahasa-indonesia)

## Tech stack

Flutter, Firebase (Authentication, Cloud Firestore for data, Cloud Storage for images), `image_picker` for photo uploads, `cached_network_image` so listing photos don't get re-downloaded on every scroll.

## Getting started

```bash
flutter pub get
```

Set up a Firebase project and add your own `google-services.json` (Android) and `GoogleService-Info.plist` (iOS); neither is committed to this repository, since each is tied to a specific Firebase project and contains that project's identifiers. Firestore's security rules are in `firestore.rules`, and Cloud Storage's access rules are in `storage.rules`; apply both to your Firebase project so that, for example, a user cannot read or modify another user's private data.

```bash
flutter run
```

## Project structure

```
lib/screens/    login, registration, and the main screen shell
lib/tabs/       the comparison tab, dashboard tab, and profile tab
lib/services/   Firebase access: auth, Firestore queries, Storage uploads
lib/models/     data models (listings, users)
```

---

## Bahasa Indonesia

Banding.in adalah aplikasi Flutter untuk mahasiswa membandingkan harga barang bekas dengan mahasiswa lain di kampusnya sendiri, gagasan "jual-beli hanya di lingkaran yang dipercaya" yang sama seperti BBB.id tetapi menyasar perbandingan harga, bukan alur marketplace lengkap. Mahasiswa memasang barang dengan harganya, menelusuri yang dipasang mahasiswa lain, memfilter hasil, dan bisa chat dengan penjual sebelum memutuskan apakah suatu harga wajar, dengan riwayat lengkap yang tersimpan sebagai referensi.

### Teknologi

Flutter, Firebase (Authentication, Cloud Firestore untuk data, Cloud Storage untuk gambar), `image_picker` untuk unggah foto, `cached_network_image` agar foto listing tidak diunduh ulang setiap kali di-scroll.

### Menjalankan

```bash
flutter pub get
```

Siapkan proyek Firebase dan tambahkan `google-services.json` (Android) dan `GoogleService-Info.plist` (iOS) milik sendiri; keduanya tidak disertakan di repositori ini, karena masing-masing terkait ke proyek Firebase tertentu dan berisi identifier proyek itu. Aturan keamanan Firestore ada di `firestore.rules`, dan aturan akses Cloud Storage di `storage.rules`; terapkan keduanya ke proyek Firebase Anda agar, misalnya, satu pengguna tidak bisa membaca atau mengubah data privat pengguna lain.

```bash
flutter run
```

### Struktur

```
lib/screens/    login, pendaftaran, dan shell layar utama
lib/tabs/       tab perbandingan, tab dashboard, dan tab profil
lib/services/   akses Firebase: auth, query Firestore, unggah Storage
lib/models/     model data (listing, pengguna)
```
