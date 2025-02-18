<<<<<<< HEAD
# dart_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
=======
# Note-Taker

A Flutter-based application for capturing images, detecting text, and managing notes efficiently.

## Features
- 📸 **Capture Images**: Open the camera to take pictures.
- 📝 **Text Recognition**: Extract text from images using Google ML Kit.
- 💾 **Save Notes**: Store images along with recognized text.
- 📂 **Gallery View**: Manage and browse saved notes.
- 📋 **Copy Text**: Easily copy extracted text to clipboard.

## Getting Started
This project is built with Flutter. To set it up locally:

### Prerequisites
- Install [Flutter SDK](https://flutter.dev/docs/get-started/install).
- Install Dart.
- Ensure you have a connected device or an emulator running.

### Installation
1. **Clone the repository:**
   ```sh
   git clone https://github.com/AFK07/Note-Taker.git
   cd Note-Taker
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Run the app:**
   ```sh
   flutter run
   ```

## Folder Structure
```sh
lib/
 ├── core/               # Business logic (services, utilities)
 │   ├── models/         # Data models
 │   ├── services/       # Backend logic (text detection, camera, storage)
 │   ├── utils/          # Helper functions
 │
 ├── ui/                 # UI screens
 │   ├── camera/         # Camera screen & image preview
 │   ├── text_detect/    # Text detection UI
 │   ├── saved/          # Saved notes & gallery
 │   ├── home/           # Home screen
 │
 ├── widgets/            # Reusable UI components
 ├── main.dart           # Entry point
```

## Resources
- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Google ML Kit](https://developers.google.com/ml-kit)

## License
This project is licensed under the MIT License. See `LICENSE` for details.
>>>>>>> cebe4a2 (progress report of note taking application)
