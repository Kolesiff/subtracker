# MVVM Architecture Guide

## Overview

MVVM (Model-View-ViewModel) separates concerns:
- **Model**: Data layer (services, repositories, data models)
- **View**: UI layer (widgets, screens)
- **ViewModel**: Business logic, state management, connects Model to View

## Folder Structure

```
lib/
├── data/                    # MODEL LAYER
│   ├── models/              # Data transfer objects
│   │   └── user_model.dart
│   ├── repositories/        # Repository implementations
│   │   └── user_repository_impl.dart
│   └── services/            # External services
│       ├── api_service.dart
│       └── local_storage_service.dart
│
├── domain/                  # DOMAIN LAYER (optional, for clean architecture)
│   ├── entities/            # Business entities
│   │   └── user.dart
│   └── repositories/        # Repository interfaces
│       └── user_repository.dart
│
├── presentation/            # VIEW & VIEWMODEL LAYER
│   ├── screens/
│   │   └── home/
│   │       ├── home_screen.dart      # VIEW
│   │       └── home_viewmodel.dart   # VIEWMODEL
│   └── widgets/             # Reusable widgets
│
└── core/                    # Shared utilities
    ├── constants/
    ├── theme/
    └── utils/
```

## Implementation Examples

### Model (Data Class)
```dart
// data/models/user_model.dart
class UserModel {
  final String id;
  final String name;
  final String email;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };
}
```

### Service (API calls)
```dart
// data/services/user_service.dart
import 'package:dio/dio.dart';

class UserService {
  final Dio _dio;
  
  UserService(this._dio);

  Future<List<UserModel>> fetchUsers() async {
    final response = await _dio.get('/users');
    return (response.data as List)
        .map((json) => UserModel.fromJson(json))
        .toList();
  }

  Future<UserModel> fetchUser(String id) async {
    final response = await _dio.get('/users/$id');
    return UserModel.fromJson(response.data);
  }
}
```

### Repository Interface
```dart
// domain/repositories/user_repository.dart
abstract class UserRepository {
  Future<List<UserModel>> getUsers();
  Future<UserModel> getUser(String id);
}
```

### Repository Implementation
```dart
// data/repositories/user_repository_impl.dart
class UserRepositoryImpl implements UserRepository {
  final UserService _userService;

  UserRepositoryImpl(this._userService);

  @override
  Future<List<UserModel>> getUsers() async {
    return await _userService.fetchUsers();
  }

  @override
  Future<UserModel> getUser(String id) async {
    return await _userService.fetchUser(id);
  }
}
```

### ViewModel (with ChangeNotifier)
```dart
// presentation/screens/home/home_viewmodel.dart
import 'package:flutter/foundation.dart';

enum ViewState { idle, loading, success, error }

class HomeViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  HomeViewModel(this._userRepository);

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  List<UserModel> _users = [];
  List<UserModel> get users => _users;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadUsers() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      _users = await _userRepository.getUsers();
      _state = ViewState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
    }
    notifyListeners();
  }
}
```

### View (Screen)
```dart
// presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          switch (viewModel.state) {
            case ViewState.loading:
              return const Center(child: CircularProgressIndicator());
            case ViewState.error:
              return Center(child: Text('Error: ${viewModel.errorMessage}'));
            case ViewState.success:
              return ListView.builder(
                itemCount: viewModel.users.length,
                itemBuilder: (context, index) {
                  final user = viewModel.users[index];
                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text(user.email),
                  );
                },
              );
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
```

### Dependency Injection Setup
```dart
// main.dart
import 'package:provider/provider.dart';

void main() {
  // Create services
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
  final userService = UserService(dio);
  final userRepository = UserRepositoryImpl(userService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(userRepository),
        ),
        // Add more providers as needed
      ],
      child: const MyApp(),
    ),
  );
}
```

## Best Practices

1. **Separation of Concerns**: Views should not contain business logic
2. **Single Responsibility**: Each ViewModel handles one feature/screen
3. **Testability**: ViewModels should be easily unit testable
4. **Dependency Injection**: Inject dependencies for flexibility
5. **State Management**: Use notifyListeners() sparingly for performance

## Data Flow

```
User Interaction → View → ViewModel → Repository → Service → API/DB
                    ↑         |
                    |_________|
                  (notifyListeners)
```

## Alternative: GetIt for DI

```dart
// injection.dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Services
  getIt.registerLazySingleton(() => Dio());
  getIt.registerLazySingleton(() => UserService(getIt()));
  
  // Repositories
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt()),
  );
  
  // ViewModels
  getIt.registerFactory(() => HomeViewModel(getIt()));
}

// Usage in main.dart
void main() {
  setupDependencies();
  runApp(const MyApp());
}

// Usage in screens
final viewModel = getIt<HomeViewModel>();
```
