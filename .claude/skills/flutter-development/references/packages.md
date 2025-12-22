# Essential Flutter Packages Guide

## State Management

| Package | Use Case | Complexity |
|---------|----------|------------|
| [provider](https://pub.dev/packages/provider) | Simple-medium apps | Low |
| [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) | Medium-large apps | Medium |
| [flutter_bloc](https://pub.dev/packages/flutter_bloc) | Enterprise apps | High |
| [get](https://pub.dev/packages/get) | Rapid development | Low |

```yaml
dependencies:
  provider: ^6.1.1
  flutter_riverpod: ^2.4.9
  flutter_bloc: ^8.1.3
  get: ^4.6.6
```

---

## Networking

### HTTP Client
```yaml
dependencies:
  dio: ^5.4.0           # Full-featured HTTP client
  http: ^1.2.0          # Simple HTTP requests
  retrofit: ^4.1.0      # Type-safe REST client
```

### Dio Example
```dart
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: const Duration(seconds: 5),
  receiveTimeout: const Duration(seconds: 3),
));

// Add interceptors
dio.interceptors.add(LogInterceptor());
dio.interceptors.add(AuthInterceptor());

final response = await dio.get('/users');
```

---

## Local Storage

| Package | Use Case |
|---------|----------|
| [shared_preferences](https://pub.dev/packages/shared_preferences) | Simple key-value |
| [hive](https://pub.dev/packages/hive) | Fast NoSQL database |
| [sqflite](https://pub.dev/packages/sqflite) | SQLite database |
| [drift](https://pub.dev/packages/drift) | Type-safe SQLite |

```yaml
dependencies:
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  sqflite: ^2.3.2
```

### Shared Preferences Example
```dart
final prefs = await SharedPreferences.getInstance();

// Save
await prefs.setString('token', 'abc123');
await prefs.setBool('darkMode', true);

// Read
final token = prefs.getString('token');
final darkMode = prefs.getBool('darkMode') ?? false;
```

---

## Navigation

```yaml
dependencies:
  go_router: ^13.0.0      # Declarative routing
  auto_route: ^7.8.4      # Code generation routing
```

---

## UI Components

### Core UI
```yaml
dependencies:
  flutter_svg: ^2.0.9           # SVG support
  cached_network_image: ^3.3.1  # Image caching
  shimmer: ^3.0.0               # Loading placeholders
  flutter_spinkit: ^5.2.0       # Loading spinners
```

### Forms & Input
```yaml
dependencies:
  flutter_form_builder: ^9.2.1  # Form handling
  form_builder_validators: ^9.1.0
  pin_code_fields: ^8.0.1       # OTP input
  intl_phone_field: ^3.2.0      # Phone input
```

### Lists & Grids
```yaml
dependencies:
  infinite_scroll_pagination: ^4.0.0  # Pagination
  pull_to_refresh: ^2.0.0             # Pull to refresh
  flutter_staggered_grid_view: ^0.7.0 # Masonry grid
```

---

## Animations

```yaml
dependencies:
  lottie: ^3.0.0              # Lottie animations
  flutter_animate: ^4.3.0     # Easy animations
  animations: ^2.0.11         # Material animations
  rive: ^0.13.0               # Rive animations
```

### Flutter Animate Example
```dart
Text('Hello')
    .animate()
    .fadeIn(duration: 500.ms)
    .slideX(begin: -0.2, end: 0);
```

---

## Backend Integration

### Firebase
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
  firebase_messaging: ^14.7.9
```

### Supabase
```yaml
dependencies:
  supabase_flutter: ^2.3.0
```

---

## Authentication

```yaml
dependencies:
  google_sign_in: ^6.2.1
  sign_in_with_apple: ^6.1.0
  flutter_facebook_auth: ^7.0.0
  local_auth: ^2.1.8           # Biometrics
```

---

## Device Features

### Permissions
```yaml
dependencies:
  permission_handler: ^11.2.0
```

```dart
final status = await Permission.camera.request();
if (status.isGranted) {
  // Use camera
}
```

### Location
```yaml
dependencies:
  geolocator: ^11.0.0
  geocoding: ^2.1.1
```

### Camera & Media
```yaml
dependencies:
  image_picker: ^1.0.7
  camera: ^0.10.5+9
  video_player: ^2.8.2
```

### Other Device Features
```yaml
dependencies:
  url_launcher: ^6.2.4        # Open URLs
  share_plus: ^7.2.2          # Share content
  connectivity_plus: ^5.0.2   # Network status
  device_info_plus: ^9.1.2    # Device info
  package_info_plus: ^5.0.1   # App info
```

---

## Utilities

### Code Generation
```yaml
dev_dependencies:
  build_runner: ^2.4.8
  json_serializable: ^6.7.1   # JSON parsing
  freezed: ^2.4.6             # Immutable classes
  freezed_annotation: ^2.4.1
```

### JSON Serializable Example
```dart
import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String name;
  
  User({required this.id, required this.name});
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

Run: `dart run build_runner build`

### Date/Time
```yaml
dependencies:
  intl: ^0.19.0               # Formatting
  jiffy: ^6.2.1               # Date manipulation
```

### Logging
```yaml
dependencies:
  logger: ^2.0.2+1
```

---

## Development Tools

### App Icons & Splash
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
  flutter_native_splash: ^2.3.9
```

### Linting
```yaml
dev_dependencies:
  flutter_lints: ^3.0.1       # Official lints
  very_good_analysis: ^5.1.0  # Stricter rules
```

### Testing
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  bloc_test: ^9.1.5
  integration_test:
    sdk: flutter
```

---

## Recommended Starter Template

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management (pick one)
  provider: ^6.1.1
  
  # Networking
  dio: ^5.4.0
  
  # Storage
  shared_preferences: ^2.2.2
  
  # Navigation
  go_router: ^13.0.0
  
  # UI
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  
  # Utilities
  intl: ^0.19.0
  url_launcher: ^6.2.4
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  flutter_launcher_icons: ^0.13.1
  flutter_native_splash: ^2.3.9
  build_runner: ^2.4.8
  json_serializable: ^6.7.1
```

---

## Package Evaluation Criteria

When choosing packages, check:

1. **Popularity** - Likes on pub.dev
2. **Maintenance** - Recent updates
3. **Pub Points** - Quality score (aim for 130+)
4. **Null Safety** - Must support
5. **Platform Support** - Android, iOS, Web
6. **Documentation** - Examples available
7. **Issues** - Open bugs count

---

## Useful Links

- **pub.dev**: https://pub.dev
- **Flutter Favorites**: https://pub.dev/flutter/favorites
- **Awesome Flutter**: https://github.com/Solido/awesome-flutter
