import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:subtracker/data/models/app_user.dart';
import 'package:subtracker/data/models/auth_result.dart';
import 'package:subtracker/data/repositories/auth_repository.dart';
import 'package:subtracker/presentation/account_settings/widgets/profile_header_widget.dart';
import 'package:subtracker/presentation/auth/viewmodel/auth_viewmodel.dart';
import 'package:subtracker/theme/app_theme.dart';

/// A minimal mock auth repository for widget testing
class SimpleTestAuthRepository implements AuthRepository {
  AppUser? _currentUser;

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
    _currentUser = null;
    return AuthResult.success(AppUser(id: '', email: '', createdAt: DateTime.now()));
  }

  @override
  Future<AuthResult> resetPassword({required String email}) async {
    throw UnimplementedError();
  }
}

void main() {
  group('ProfileHeaderWidget', () {
    testWidgets('displays user avatar', (tester) async {
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
            child: const Scaffold(body: ProfileHeaderWidget()),
          ),
        ),
      );

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);

      viewModel.dispose();
    });

    testWidgets('displays user email', (tester) async {
      final user = AppUser(
        id: 'test-id',
        email: 'john@example.com',
        createdAt: DateTime.now(),
      );
      final repository = SimpleTestAuthRepository(currentUser: user);
      final viewModel = AuthViewModel(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: ProfileHeaderWidget()),
          ),
        ),
      );

      expect(find.text('john@example.com'), findsOneWidget);

      viewModel.dispose();
    });

    testWidgets('displays display name when available', (tester) async {
      final user = AppUser(
        id: 'test-id',
        email: 'john@example.com',
        displayName: 'John Doe',
        createdAt: DateTime.now(),
      );
      final repository = SimpleTestAuthRepository(currentUser: user);
      final viewModel = AuthViewModel(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: ProfileHeaderWidget()),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);

      viewModel.dispose();
    });

    testWidgets('shows email as name when display name not available', (tester) async {
      final user = AppUser(
        id: 'test-id',
        email: 'jane@example.com',
        createdAt: DateTime.now(),
      );
      final repository = SimpleTestAuthRepository(currentUser: user);
      final viewModel = AuthViewModel(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: ProfileHeaderWidget()),
          ),
        ),
      );

      // Should show email as the name
      expect(find.text('jane@example.com'), findsWidgets);

      viewModel.dispose();
    });

    testWidgets('shows placeholder when not authenticated', (tester) async {
      final repository = SimpleTestAuthRepository(currentUser: null);
      final viewModel = AuthViewModel(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AuthViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: ProfileHeaderWidget()),
          ),
        ),
      );

      // Should still show avatar even if no user
      expect(find.byType(CircleAvatar), findsOneWidget);

      viewModel.dispose();
    });
  });
}
