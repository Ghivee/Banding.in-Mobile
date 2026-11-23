# Banding.in

A Flutter app for comparing secondhand item prices among university students: catalog, filters, chat and history, built on Firebase.

[Bahasa Indonesia](README.id.md)

## Tech stack

Flutter, Firebase (Auth, Cloud Firestore, Storage), `image_picker`, `cached_network_image`.

## Getting started

```bash
flutter pub get
```

Set up a Firebase project and add your own `google-services.json` (Android) and `GoogleService-Info.plist` (iOS); they are not committed to this repository. Firestore security rules are in `firestore.rules`, and storage rules are in `storage.rules`.

```bash
flutter run
```

## Project structure

```
lib/screens/    login, register, main screen
lib/tabs/       comparison, dashboard, profile tabs
lib/services/   Firebase access
lib/models/     data models
```
