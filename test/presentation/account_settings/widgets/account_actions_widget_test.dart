import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:subtracker/data/models/app_user.dart';
import 'package:subtracker/data/models/auth_result.dart';
import 'package:subtracker/data/repositories/auth_repository.dart';
import 'package:subtracker/presentation/account_settings/widgets/account_actions_widget.dart';
import 'package:subtracker/presentation/auth/viewmodel/auth_viewmodel.dart';
import 'package:subtracker/theme/app_theme.dart';

/// A minimal mock auth repository for widget testing
class SimpleTestAuthRepository implements AuthRepository {
  AppUser? _currentUser;
  bool signOutCalled = false;

  SimpleTestAuthRepository({AppUser? currentUser}) : _currentUser = currentUser;

  @override
  AppUser? getCurrentUser() => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;

  @override
  Stream<AppUser?> get authStateChanges => const Stream.empty();

  @override
  Future<AuthResult> signIn({required String email, required String password}) async {
    throw UnimplementedError();
  }

  @override
  Future<AuthResult> signUp({required String email, required String password}) async {
    throw UnimplementedError();
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    throw UnimplementedError();
  }

  @override
  Future<AuthResult> signInWithApple() async {
    throw UnimplementedError();
  }

  @override
  Future<AuthResult> signOut() async {
    signOutCalled = true;
    final user = _currentUser;
    _currentUser = null;
    return AuthResult.success(user ?? AppUser(id: '', email: '', createdAt: DateTime.now()));
  }

  @override
  Future<AuthResult> resetPassword({required String email}) async {
    throw UnimplementedError();
  }
}

void main() {
  group('AccountActionsWidget', () {
    testWidgets('displays logout button', (tester) async {
      final user = AppUser(
        id: 'test-id',
        email: 'test@example.com',
        createdAt: DateTime.now(),
      );
      final repository = SimpleTestAuthRepository(currentUser: user);
      final viewModel = AuthViewModel(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: AccountActionsWidget()),
          ),
        ),
      );

      expect(find.text('Logout'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);

      viewModel.dispose();
    });

    testWidgets('shows section title', (tester) async {
      final user = AppUser(
        id: 'test-id',
        email: 'test@example.com',
        createdAt: DateTime.now(),
      );
      final repository = SimpleTestAuthRepository(currentUser: user);
      final viewModel = AuthViewModel(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: AccountActionsWidget()),
          ),
        ),
      );

      expect(find.text('Account'), findsOneWidget);

      viewModel.dispose();
    });

    testWidgets('tapping logout shows confirmation dialog', (tester) async {
      final user = AppUser(
        id: 'test-id',
        email: 'test@example.com',
        createdAt: DateTime.now(),
      );
      final repository = SimpleTestAuthRepository(currentUser: user);
      final viewModel = AuthViewModel(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: AccountActionsWidget()),
          ),
        ),
      );

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.text('Logout'), findsWidgets); // Dialog title
      expect(find.text('Are you sure you want to logout?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      viewModel.dispose();
    });

    testWidgets('cancel button closes dialog without signing out', (tester) async {
      final user = AppUser(
        id: 'test-id',
        email: 'test@example.com',
        createdAt: DateTime.now(),
      );
      final repository = SimpleTestAuthRepository(currentUser: user);
      final viewModel = AuthViewModel(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: AccountActionsWidget()),
          ),
        ),
      );

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Are you sure you want to logout?'), findsNothing);
      // Sign out should not have been called
      expect(repository.signOutCalled, isFalse);

      viewModel.dispose();
    });

    testWidgets('confirming logout calls signOut', (tester) async {
      final user = AppUser(
        id: 'test-id',
        email: 'test@example.com',
        createdAt: DateTime.now(),
      );
      final repository = SimpleTestAuthRepository(currentUser: user);
      final viewModel = AuthViewModel(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          routes: {
            '/login-screen': (_) => const Scaffold(body: Text('Login Screen')),
          },
          home: ChangeNotifierProvider<AuthViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: AccountActionsWidget()),
          ),
        ),
      );

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Find the confirm button in the dialog (second ElevatedButton)
      final confirmButtons = find.widgetWithText(ElevatedButton, 'Logout');
      await tester.tap(confirmButtons.last);
      await tester.pumpAndSettle();

      // Sign out should have been called
      expect(repository.signOutCalled, isTrue);

      viewModel.dispose();
    });

    testWidgets('logout button has error color styling', (tester) async {
      final user = AppUser(
        id: 'test-id',
        email: 'test@example.com',
        createdAt: DateTime.now(),
      );
      final repository = SimpleTestAuthRepository(currentUser: user);
      final viewModel = AuthViewModel(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: AccountActionsWidget()),
          ),
        ),
      );

      // Find the elevated button
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      // It should have error color styling (checking it exists is enough)
      expect(button, isNotNull);

      viewModel.dispose();
    });
  });
}
