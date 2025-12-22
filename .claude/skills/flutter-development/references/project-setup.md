# Project Setup Guide

## Environment Setup

### Prerequisites
- Flutter SDK: https://docs.flutter.dev/get-started/install
- Android Studio with Flutter/Dart plugins
- VS Code with Flutter extension (optional)
- Android SDK (via Android Studio)
- JDK 17+ for Android builds

### Verify Installation
```bash
flutter doctor -v
```

## Create New Project

```bash
# Basic project
flutter create app_name

# With organization (recommended)
flutter create --org com.yourcompany app_name

# Specify platforms
flutter create --platforms android app_name
```

## Project Structure (MVVM)

```
lib/
├── main.dart                 # App entry point
├── app/
│   ├── app.dart             # MaterialApp configuration
│   └── routes.dart          # Route definitions
├── core/
│   ├── constants/           # App-wide constants
│   │   ├── colors.dart
│   │   ├── strings.dart
│   │   └── sizes.dart
│   ├── theme/               # Theme configuration
│   │   ├── app_theme.dart
│   │   └── text_styles.dart
│   ├── utils/               # Helper utilities
│   │   ├── validators.dart
│   │   └── formatters.dart
│   └── extensions/          # Dart extensions
├── data/
│   ├── models/              # Data models
│   ├── repositories/        # Repository implementations
│   └── services/            # API/DB services
├── domain/
│   ├── entities/            # Business entities
│   └── repositories/        # Repository interfaces
└── presentation/
    ├── screens/             # Feature screens
    │   └── home/
    │       ├── home_screen.dart
    │       └── home_viewmodel.dart
    ├── widgets/             # Reusable widgets
    └── shared/              # Shared UI components

android/                     # Android-specific code
ios/                        # iOS-specific code
test/                       # Test files (mirrors lib/ structure)
assets/
├── images/
├── icons/
└── fonts/
```

## Essential Configuration

### pubspec.yaml
```yaml
name: app_name
description: Your app description
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  # State management (pick one)
  provider: ^6.1.1
  # OR riverpod: ^2.4.9
  # OR flutter_bloc: ^8.1.3
  
  # Networking
  dio: ^5.4.0
  
  # Local storage
  shared_preferences: ^2.2.2
  
  # Utilities
  intl: ^0.19.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  flutter_launcher_icons: ^0.13.1
  flutter_native_splash: ^2.3.9

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/CustomFont-Regular.ttf
        - asset: assets/fonts/CustomFont-Bold.ttf
          weight: 700
```

### AndroidManifest.xml Essentials
Location: `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <application
        android:label="Your App Name"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- ... -->
    </application>
</manifest>
```

### App Entry Point (main.dart)
```dart
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize services here (Firebase, etc.)
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Name',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
```

## Package Name Configuration

Update in these locations:
1. `android/app/build.gradle` → `applicationId`
2. `android/app/src/main/AndroidManifest.xml` → `package`
3. `android/app/src/debug/AndroidManifest.xml`
4. `android/app/src/profile/AndroidManifest.xml`
5. Kotlin/Java package directories

## App Icons & Splash Screen

### flutter_launcher_icons
```yaml
# pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon.png"
  min_sdk_android: 21
```
Run: `dart run flutter_launcher_icons`

### flutter_native_splash
```yaml
# pubspec.yaml
flutter_native_splash:
  color: "#FFFFFF"
  image: assets/splash/splash.png
  android: true
  ios: true
```
Run: `dart run flutter_native_splash:create`

## VS Code Settings
Create `.vscode/settings.json`:
```json
{
  "editor.formatOnSave": true,
  "dart.lineLength": 80,
  "[dart]": {
    "editor.defaultFormatter": "Dart-Code.dart-code"
  }
}
```

## Useful CLI Commands

```bash
# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Clean build
flutter clean

# Generate code (for json_serializable, etc.)
dart run build_runner build --delete-conflicting-outputs

# Format code
dart format lib/

# Analyze code
flutter analyze
```
