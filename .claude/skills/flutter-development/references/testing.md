# Flutter Testing Guide

## Test Types Overview

| Type | Purpose | Speed | Coverage |
|------|---------|-------|----------|
| Unit | Test single functions/classes | Fast | Logic |
| Widget | Test single widgets | Medium | UI components |
| Integration | Test complete flows | Slow | End-to-end |

**Recommended ratio**: Many unit tests → Fewer widget tests → Few integration tests

---

## Setup

### pubspec.yaml
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.8
  bloc_test: ^9.1.5  # If using Bloc
```

### Test Directory Structure
```
test/
├── unit/
│   ├── models/
│   │   └── user_model_test.dart
│   ├── repositories/
│   │   └── user_repository_test.dart
│   └── viewmodels/
│       └── home_viewmodel_test.dart
├── widget/
│   └── screens/
│       └── login_screen_test.dart
└── integration/
    └── app_test.dart
```

---

## Unit Testing

### Basic Test Structure
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Calculator', () {
    late Calculator calculator;

    setUp(() {
      calculator = Calculator();
    });

    test('adds two numbers correctly', () {
      expect(calculator.add(2, 3), equals(5));
    });

    test('subtracts two numbers correctly', () {
      expect(calculator.subtract(5, 3), equals(2));
    });

    test('throws on division by zero', () {
      expect(
        () => calculator.divide(10, 0),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
```

### Testing Models
```dart
void main() {
  group('UserModel', () {
    test('creates from JSON correctly', () {
      final json = {
        'id': '123',
        'name': 'John Doe',
        'email': 'john@example.com',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, equals('123'));
      expect(user.name, equals('John Doe'));
      expect(user.email, equals('john@example.com'));
    });

    test('converts to JSON correctly', () {
      final user = UserModel(
        id: '123',
        name: 'John Doe',
        email: 'john@example.com',
      );

      final json = user.toJson();

      expect(json['id'], equals('123'));
      expect(json['name'], equals('John Doe'));
    });
  });
}
```

### Mocking with Mockito
```dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Generate mocks
@GenerateMocks([UserRepository])
import 'user_repository_test.mocks.dart';

void main() {
  late MockUserRepository mockRepository;
  late UserService userService;

  setUp(() {
    mockRepository = MockUserRepository();
    userService = UserService(mockRepository);
  });

  test('fetches user successfully', () async {
    // Arrange
    final expectedUser = UserModel(id: '1', name: 'John', email: 'j@e.com');
    when(mockRepository.getUser('1'))
        .thenAnswer((_) async => expectedUser);

    // Act
    final result = await userService.getUser('1');

    // Assert
    expect(result, equals(expectedUser));
    verify(mockRepository.getUser('1')).called(1);
  });

  test('throws when user not found', () async {
    when(mockRepository.getUser('999'))
        .thenThrow(Exception('User not found'));

    expect(
      () => userService.getUser('999'),
      throwsException,
    );
  });
}
```

Run: `dart run build_runner build` to generate mocks.

### Testing ViewModels
```dart
void main() {
  late MockUserRepository mockRepository;
  late HomeViewModel viewModel;

  setUp(() {
    mockRepository = MockUserRepository();
    viewModel = HomeViewModel(mockRepository);
  });

  group('loadUsers', () {
    test('sets loading state while fetching', () async {
      when(mockRepository.getUsers())
          .thenAnswer((_) async => []);

      final future = viewModel.loadUsers();

      expect(viewModel.state, equals(ViewState.loading));

      await future;
    });

    test('sets success state with users', () async {
      final users = [UserModel(id: '1', name: 'John', email: 'j@e.com')];
      when(mockRepository.getUsers())
          .thenAnswer((_) async => users);

      await viewModel.loadUsers();

      expect(viewModel.state, equals(ViewState.success));
      expect(viewModel.users, equals(users));
    });

    test('sets error state on failure', () async {
      when(mockRepository.getUsers())
          .thenThrow(Exception('Network error'));

      await viewModel.loadUsers();

      expect(viewModel.state, equals(ViewState.error));
      expect(viewModel.errorMessage, contains('Network error'));
    });
  });
}
```

---

## Widget Testing

### Basic Widget Test
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments when tapped', (WidgetTester tester) async {
    // Build widget
    await tester.pumpWidget(const MaterialApp(home: CounterScreen()));

    // Verify initial state
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump(); // Rebuild widget

    // Verify new state
    expect(find.text('1'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });
}
```

### Finding Widgets
```dart
// By type
find.byType(ElevatedButton)

// By text
find.text('Submit')

// By key
find.byKey(const Key('login_button'))

// By icon
find.byIcon(Icons.add)

// By widget predicate
find.byWidgetPredicate((widget) => widget is Text && widget.data == 'Hello')

// Descendant/Ancestor
find.descendant(
  of: find.byType(Card),
  matching: find.text('Title'),
)
```

### User Interactions
```dart
// Tap
await tester.tap(find.byType(ElevatedButton));

// Long press
await tester.longPress(find.byType(ListTile));

// Enter text
await tester.enterText(find.byType(TextField), 'test@example.com');

// Scroll
await tester.drag(find.byType(ListView), const Offset(0, -300));

// Swipe
await tester.fling(find.byType(Dismissible), const Offset(-300, 0), 1000);
```

### Testing with Provider
```dart
testWidgets('displays user name from provider', (tester) async {
  final mockViewModel = MockHomeViewModel();
  when(mockViewModel.state).thenReturn(ViewState.success);
  when(mockViewModel.users).thenReturn([
    UserModel(id: '1', name: 'John', email: 'j@e.com'),
  ]);

  await tester.pumpWidget(
    MaterialApp(
      home: ChangeNotifierProvider<HomeViewModel>.value(
        value: mockViewModel,
        child: const HomeScreen(),
      ),
    ),
  );

  expect(find.text('John'), findsOneWidget);
});
```

### Testing Navigation
```dart
testWidgets('navigates to details on tap', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: const HomeScreen(),
      routes: {
        '/details': (_) => const DetailsScreen(),
      },
    ),
  );

  await tester.tap(find.text('View Details'));
  await tester.pumpAndSettle(); // Wait for navigation animation

  expect(find.byType(DetailsScreen), findsOneWidget);
});
```

### Golden Tests (Screenshot Tests)
```dart
testWidgets('matches golden file', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: MyWidget()));

  await expectLater(
    find.byType(MyWidget),
    matchesGoldenFile('goldens/my_widget.png'),
  );
});
```

Run: `flutter test --update-goldens` to generate/update golden files.

---

## Integration Testing

### Setup
Create `integration_test/app_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('complete login flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find and fill email field
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );

      // Find and fill password field
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Tap login button
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify navigation to home
      expect(find.text('Welcome'), findsOneWidget);
    });
  });
}
```

### Run Integration Tests
```bash
# On connected device/emulator
flutter test integration_test/app_test.dart

# On specific device
flutter test integration_test --device-id=<device-id>
```

---

## Testing Async Code

```dart
test('fetches data asynchronously', () async {
  final result = await repository.fetchData();
  expect(result, isNotEmpty);
});

test('stream emits values', () async {
  expect(
    counterStream,
    emitsInOrder([1, 2, 3]),
  );
});
```

---

## Commands

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/user_model_test.dart

# Run with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html

# Run tests in watch mode (with flutter_test_watcher)
flutter pub run flutter_test_watcher
```

---

## Best Practices

1. **Test behavior, not implementation**
2. **Use descriptive test names**: `should_return_error_when_email_invalid`
3. **Arrange-Act-Assert pattern**
4. **Keep tests independent**: Use setUp/tearDown
5. **Mock external dependencies**: Network, database, etc.
6. **Test edge cases**: Empty lists, null values, errors
7. **Aim for 80%+ code coverage** on business logic
8. **Run tests in CI/CD pipeline**
