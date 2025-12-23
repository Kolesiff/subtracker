import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/data/models/models.dart';
import 'package:subtracker/data/repositories/mock_auth_repository.dart';
import 'package:subtracker/presentation/auth/viewmodel/auth_viewmodel.dart';

void main() {
  late MockAuthRepository repository;
  late AuthViewModel viewModel;

  setUp(() {
    repository = MockAuthRepository();
    viewModel = AuthViewModel(repository: repository);
  });

  tearDown(() {
    viewModel.dispose();
    repository.dispose();
  });

  group('AuthViewModel', () {
    group('Initial State', () {
      test('should have idle status initially', () {
        expect(viewModel.status, equals(AuthStatus.idle));
      });

      test('should have no current user initially', () {
        expect(viewModel.currentUser, isNull);
      });

      test('should not be authenticated initially', () {
        expect(viewModel.isAuthenticated, isFalse);
      });

      test('should have no error message initially', () {
        expect(viewModel.errorMessage, isNull);
      });

      test('should not be loading initially', () {
        expect(viewModel.isLoading, isFalse);
      });
    });

    group('signUp', () {
      test('should set status to loading during sign up', () async {
        final statuses = <AuthStatus>[];
        viewModel.addListener(() => statuses.add(viewModel.status));

        final future = viewModel.signUp(
          email: 'test@example.com',
          password: 'SecurePass123!',
        );

        expect(statuses.contains(AuthStatus.loading), isTrue);
        await future;
      });

      test('should set authenticated status on successful sign up', () async {
        await viewModel.signUp(
          email: 'test@example.com',
          password: 'SecurePass123!',
        );

        expect(viewModel.status, equals(AuthStatus.authenticated));
        expect(viewModel.currentUser, isNotNull);
        expect(viewModel.currentUser!.email, equals('test@example.com'));
        expect(viewModel.isAuthenticated, isTrue);
      });

      test('should set error status on failed sign up', () async {
        await viewModel.signUp(
          email: 'invalid-email',
          password: 'SecurePass123!',
        );

        expect(viewModel.status, equals(AuthStatus.error));
        expect(viewModel.errorMessage, isNotNull);
        expect(viewModel.isAuthenticated, isFalse);
      });

      test('should clear previous error on new attempt', () async {
        // First attempt - fail
        await viewModel.signUp(email: 'invalid', password: 'Pass123!');
        expect(viewModel.errorMessage, isNotNull);

        // Second attempt - should clear error during loading
        bool errorCleared = false;
        viewModel.addListener(() {
          if (viewModel.status == AuthStatus.loading && viewModel.errorMessage == null) {
            errorCleared = true;
          }
        });

        await viewModel.signUp(email: 'valid@example.com', password: 'SecurePass123!');
        expect(errorCleared, isTrue);
      });
    });

    group('signIn', () {
      setUp(() async {
        await repository.signUp(email: 'existing@example.com', password: 'SecurePass123!');
        await repository.signOut();
      });

      test('should authenticate on successful sign in', () async {
        await viewModel.signIn(
          email: 'existing@example.com',
          password: 'SecurePass123!',
        );

        expect(viewModel.status, equals(AuthStatus.authenticated));
        expect(viewModel.isAuthenticated, isTrue);
      });

      test('should show error for wrong password', () async {
        await viewModel.signIn(
          email: 'existing@example.com',
          password: 'WrongPassword123!',
        );

        expect(viewModel.status, equals(AuthStatus.error));
        expect(viewModel.errorMessage, isNotNull);
      });

      test('should show error for non-existent user', () async {
        await viewModel.signIn(
          email: 'nobody@example.com',
          password: 'Password123!',
        );

        expect(viewModel.status, equals(AuthStatus.error));
        expect(viewModel.errorMessage, isNotNull);
      });
    });

    group('signInWithGoogle', () {
      test('should authenticate on successful Google sign in', () async {
        await viewModel.signInWithGoogle();

        expect(viewModel.status, equals(AuthStatus.authenticated));
        expect(viewModel.currentUser?.provider, equals(AuthProvider.google));
      });

      test('should reset to idle when Google sign in cancelled', () async {
        repository.simulateGoogleSignInCancelled();

        await viewModel.signInWithGoogle();

        expect(viewModel.status, equals(AuthStatus.idle));
        expect(viewModel.errorMessage, isNull);
      });

      test('should show error on network failure', () async {
        repository.simulateNetworkError();

        await viewModel.signInWithGoogle();

        expect(viewModel.status, equals(AuthStatus.error));
        expect(viewModel.errorMessage, isNotNull);
      });
    });

    group('signInWithApple', () {
      test('should authenticate on successful Apple sign in', () async {
        await viewModel.signInWithApple();

        expect(viewModel.status, equals(AuthStatus.authenticated));
        expect(viewModel.currentUser?.provider, equals(AuthProvider.apple));
      });

      test('should show error when Apple sign in unavailable', () async {
        repository.simulateAppleSignInUnavailable();

        await viewModel.signInWithApple();

        expect(viewModel.status, equals(AuthStatus.error));
        expect(viewModel.errorMessage, isNotNull);
      });
    });

    group('signOut', () {
      test('should clear user and set idle status', () async {
        await viewModel.signUp(
          email: 'test@example.com',
          password: 'SecurePass123!',
        );
        expect(viewModel.isAuthenticated, isTrue);

        await viewModel.signOut();

        expect(viewModel.status, equals(AuthStatus.idle));
        expect(viewModel.currentUser, isNull);
        expect(viewModel.isAuthenticated, isFalse);
      });
    });

    group('resetPassword', () {
      test('should set success status on reset request', () async {
        await viewModel.resetPassword(email: 'test@example.com');

        expect(viewModel.status, equals(AuthStatus.success));
      });

      test('should show error for invalid email', () async {
        await viewModel.resetPassword(email: 'not-an-email');

        expect(viewModel.status, equals(AuthStatus.error));
        expect(viewModel.errorMessage, isNotNull);
      });
    });

    group('clearError', () {
      test('should clear error message and reset to idle', () async {
        await viewModel.signIn(email: 'invalid', password: 'pass');
        expect(viewModel.errorMessage, isNotNull);

        viewModel.clearError();

        expect(viewModel.errorMessage, isNull);
        expect(viewModel.status, equals(AuthStatus.idle));
      });
    });

    group('Form Validation Helpers', () {
      test('validateEmail should return null for valid email', () {
        expect(viewModel.validateEmail('test@example.com'), isNull);
      });

      test('validateEmail should return error for invalid email', () {
        expect(viewModel.validateEmail('invalid'), isNotNull);
        expect(viewModel.validateEmail(''), isNotNull);
        expect(viewModel.validateEmail(null), isNotNull);
      });

      test('validatePassword should return null for valid password', () {
        expect(viewModel.validatePassword('SecurePass123!'), isNull);
      });

      test('validatePassword should return error for weak password', () {
        expect(viewModel.validatePassword('weak'), isNotNull);
        expect(viewModel.validatePassword(''), isNotNull);
        expect(viewModel.validatePassword(null), isNotNull);
        expect(viewModel.validatePassword('nouppercase1'), isNotNull);
        expect(viewModel.validatePassword('NOLOWERCASE1'), isNotNull);
        expect(viewModel.validatePassword('NoNumbers'), isNotNull);
      });

      test('validateConfirmPassword should match original', () {
        expect(viewModel.validateConfirmPassword('Pass123!', 'Pass123!'), isNull);
        expect(viewModel.validateConfirmPassword('Pass123!', 'Different!'), isNotNull);
        expect(viewModel.validateConfirmPassword('Pass123!', null), isNotNull);
      });
    });

    group('Notification Behavior', () {
      test('should notify listeners on status change', () async {
        int notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        await viewModel.signUp(
          email: 'test@example.com',
          password: 'SecurePass123!',
        );

        // Should notify at least twice: loading + authenticated
        expect(notificationCount, greaterThanOrEqualTo(2));
      });

      test('should notify listeners on error', () async {
        int notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        await viewModel.signUp(
          email: 'invalid',
          password: 'SecurePass123!',
        );

        expect(notificationCount, greaterThanOrEqualTo(2));
      });
    });

    group('Auth State Stream Subscription', () {
      test('should update state when auth stream emits authenticated user', () async {
        // Sign up through repository directly (simulating OAuth callback completing)
        await repository.signUp(email: 'external@example.com', password: 'SecurePass123!');

        // Give the stream time to emit and ViewModel to process
        await Future.delayed(const Duration(milliseconds: 100));

        // ViewModel should have picked up the auth state change
        expect(viewModel.isAuthenticated, isTrue);
        expect(viewModel.currentUser, isNotNull);
        expect(viewModel.currentUser!.email, equals('external@example.com'));
        expect(viewModel.status, equals(AuthStatus.authenticated));
      });

      test('should update state when auth stream emits null (signed out)', () async {
        // First sign in
        await viewModel.signUp(email: 'test@example.com', password: 'SecurePass123!');
        expect(viewModel.isAuthenticated, isTrue);

        // Sign out through repository directly (simulating external sign out)
        await repository.signOut();

        // Give the stream time to emit and ViewModel to process
        await Future.delayed(const Duration(milliseconds: 100));

        // ViewModel should have detected the sign out
        expect(viewModel.isAuthenticated, isFalse);
        expect(viewModel.currentUser, isNull);
        expect(viewModel.status, equals(AuthStatus.idle));
      });

      test('should update when external OAuth sign in completes', () async {
        // Simulate external OAuth completing (like deep link callback)
        // by calling repository directly
        await repository.signInWithGoogle();

        // Give the stream time to emit
        await Future.delayed(const Duration(milliseconds: 100));

        // ViewModel should have picked up the change via stream
        expect(viewModel.isAuthenticated, isTrue);
        expect(viewModel.currentUser?.provider, equals(AuthProvider.google));
      });

      test('should detect auth change from another source', () async {
        // Create a fresh repository to simulate "external" auth
        final anotherAuthSource = MockAuthRepository();

        // The viewModel should subscribe to authStateChanges
        // and react to any auth state emissions

        // First, verify we're not authenticated
        expect(viewModel.isAuthenticated, isFalse);

        // Sign in through the shared repository
        await repository.signInWithGoogle();

        await Future.delayed(const Duration(milliseconds: 100));

        // ViewModel should update via stream subscription
        expect(viewModel.isAuthenticated, isTrue);

        anotherAuthSource.dispose();
      });
    });
  });
}
