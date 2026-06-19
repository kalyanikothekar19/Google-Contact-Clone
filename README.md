# MyContacts 📱

A clean and simple contacts app built with Flutter.

## Features
- Add, edit, and delete contacts
- Pick contact photo from camera or gallery
- Mark contacts as favorites
- Search contacts and favorites
- Alphabetical grouping
- Call directly from the app
- Fully offline — data stored locally using SQLite

## Tech Stack
- Flutter & Dart
- BLoC (flutter_bloc) for state management
- SQLite (sqflite) for local database
- path_provider for local image storage
- image_picker for camera/gallery access
- url_launcher for phone calls

## Architecture
- BLoC pattern for clean separation of concerns
- Repository pattern for data access
- Single source of truth via ContactBloc

## Screenshots
(add your screenshots here)

## APK Download
https://drive.google.com/drive/folders/1m7CXOSs_xfvw4zSE-ZRm9k9afnA77bQ5?usp=sharing

## Getting Started
```bash
flutter pub get
flutter run
```