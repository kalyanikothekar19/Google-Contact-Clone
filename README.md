# MyContacts 📱

A production-grade contacts management application built with Flutter, demonstrating modern mobile development practices with cloud backend integration and reactive state management.

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

Presentation Layer (UI)
         ↓
    BLoC Layer (Business Logic)
         ↓
  Repository Layer (Data Access)
         ↓
Data Layer (Firebase, SQLite)

## APK Download
https://drive.google.com/drive/folders/1m7CXOSs_xfvw4zSE-ZRm9k9afnA77bQ5?usp=sharing

## Getting Started
```bash
flutter pub get
flutter run
```
