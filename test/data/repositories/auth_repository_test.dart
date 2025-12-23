import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/data/models/models.dart';
import 'package:subtracker/data/repositories/mock_auth_repository.dart';

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  tearDown(() {
    repository.dispose();
  });

  group('AuthRepository Contract Tests', () {
    group('signUp', () {
      test('should return AppUser on successful signup', () async {
        const email = 'test@example.com';
        const password = 'SecurePass123!';

        final result = await repository.signUp(email: email, password: password);

        expect(result.isSuccess, isTrue);
        expect(result.user, isNotNull);
        expect(result.user!.email, equals(email));
        expect(result.user!.id, isNotEmpty);
      });

      test('should return failure for invalid email format', () async {
        const email = 'invalid-email';
        const password = 'SecurePass123!';

        final result = await repository.signUp(email: email, password: password);

        expect(result.isFailure, isTrue);
        expect(result.error, equals(AuthError.invalidEmail));
      });

      test('should return failure for empty email', () async {
        const email = '';
        const password = 'SecurePass123!';

        final result = await repository.signUp(email: email, password: password);

        expect(result.isFailure, isTrue);
        expect(result.error, equals(AuthError.invalidEmail));
      });

      test('should return failure for weak password - too short', () async {
        const email = 'test@example.com';
        const password = '123';

        final result = await repository.signUp(email: email, password: password);

        expect(result.isFailure, isTrue);
        expect(result.error, equals(AuthError.weakPassword));
      });

      test('should return failure for weak password - no uppercase', () async {
        const email = 'test@example.com';
        const password = 'password123';

        final result = await repository.signUp(email: email, password: password);

        expect(result.isFailure, isTrue);
        expect(result.error, equals(AuthError.weakPassword));
      });

      test('should return failure for weak password - no number', () async {
        const email = 'test@example.com';
        const password = 'PasswordOnly';

        final result = await repository.signUp(email: email, password: password);

        expect(result.isFailure, isTrue);
        expect(result.error, equals(AuthError.weakPassword));
      });

      test('should return failure for already registered email', () async {
        const email = 'existing@example.com';
        const password = 'SecurePass123!';
        await repository.signUp(email: email, password: password);

        final result = await repository.signUp(email: email, password: password);

        expect(result.isFailure, isTrue);
        expect(result.error, equals(AuthError.emailAlreadyInUse));
      });

      test('should trim whitespace from email', () async {
        final result = await repository.signUp(
          email: '  test@example.com  ',
          password: 'SecurePass123!',
        );

        expect(result.isSuccess, isTrue);
        expect(result.user!.email, equals('test@example.com'));
      });

      test('should set user as authenticated after signup', () async {
        await repository.signUp(
          email: 'test@example.com',
          password: 'SecurePass123!',
        );

        expect(repository.isAuthenticated, isTrue);
        expect(repository.getCurrentUser(), isNotNull);
      });
    });

    group('signIn', () {
      setUp(() async {
        await repository.signUp(
          email: 'existing@example.com',
          password: 'SecurePass123!',
        );
        await repository.signOut();
      });

      test('should return AppUser on successful sign in', () async {
        final result = await repository.signIn(
          email: 'existing@example.com',
          password: 'SecurePass123!',
        );

        expect(result.isSuccess, isTrue);
        expect(result.user!.email, equals('existing@example.com'));
      });

      test('should return failure for non-existent user', () async {
        final result = await repository.signIn(
          email: 'nobody@example.com',
          password: 'Password123!',
        );

        expect(result.isFailure, isTrue);
        expect(result.error, equals(AuthError.userNotFound));
      });

      test('should return failure for wrong password', () async {
        final result = await repository.signIn(
          email: 'existing@example.com',
          password: 'WrongPassword123!',
        );

        expect(result.isFailure, isTrue);
        expect(result.error, equals(AuthError.wrongPassword));
      });

      test('should set user as authenticated after sign in', () async {
        await repository.signIn(
          email: 'existing@example.com',
          password: 'SecurePass123!',
        );

        expect(repository.isAuthenticated, isTrue);
        expect(repository.getCurrentUser()!.email, equals('existing@example.com'));
      });

      test('should handle case-insensitive email', () async {
        final result = await repository.signIn(
          email: 'EXISTING@EXAMPLE.COM',
          password: 'SecurePass123!',
        );

        expect(result.isSuccess, isTrue);
      });
    });

    group('signInWithGoogle', () {
      test('should return AppUser on successful Google sign in', () async {
        final result = await repository.signInWithGoogle();

        expect(result.isSuccess, isTrue);
        expect(result.user, isNotNull);
        expect(result.user!.provider, equals(AuthProvider.google));
      });

      test('should return failure when user cancels', () async {
        repository.simulateGoogleSignInCancelled();

        final result = await repository.signInWithGoogle();

        expect(result.isFailure, isTrue);
        expect(result.error, equals(AuthError.cancelled));
      });

      test('should return failure on network error', () async {
        repository.simulateNetworkError();

        final result = await repository.signInWithGoogle();

        expect(result.isFailure, isTrue);
        expect(result.error, equals(AuthError.networkError));
      });
    });

    group('signInWithApple', () {
      test('should return AppUser on successful Apple sign in', () async {
        final result = await repository.signInWithApple();

        expect(result.isSuccess, isTrue);
        expect(result.user, isNotNull);
        expect(result.user!.provider, equals(AuthProvider.apple));
      });

      test('should return failure when not available', () async {
        repository.simulateAppleSignInUnavailable();

        final result = await repository.signInWithApple();

        expect(result.isFailure, isTrue);
        expect(result.error, equals(AuthError.notAvailable));
      });
    });

    group('signOut', () {
      test('should successfully sign out authenticated user', () async {
        await repository.signUp(
          email: 'test@example.com',
          password: 'SecurePass123!',
        );

        final result = await repository.signOut();

        expect(result.isSuccess, isTrue);
        expect(repository.isAuthenticated, isFalse);
        expect(repository.getCurrentUser(), isNull);
      });

      test('should return success even if not signed in', () async {
        final result = await repository.signOut();

        expect(result.isSuccess, isTrue);
      });
    });

    group('resetPassword', () {
      test('should succeed for valid email format', () async {
        final result = await repository.resetPassword(
          email: 'test@example.com',
        );

        expect(result.isSuccess, isTrue);
      });

      test('should return success for non-existent email (security)', () async {
        final result = await repository.resetPassword(
          email: 'unknown@example.com',
        );

        expect(result.isSuccess, isTrue);
      });

      test('should return failure for invalid email format', () async {
        final result = await repository.resetPassword(email: 'not-an-email');

        expect(result.isFailure, isTrue);
        expect(result.error, equals(AuthError.invalidEmail));
      });

      test('should return failure for empty email', () async {
        final result = await repository.resetPassword(email: '');

        expect(result.isFailure, isTrue);
        expect(result.error, equals(AuthError.invalidEmail));
      });
    });

    group('getCurrentUser', () {
      test('should return null when not authenticated', () {
        final user = repository.getCurrentUser();

        expect(user, isNull);
      });

      test('should return user after successful sign in', () async {
        const email = 'test@example.com';
        await repository.signUp(email: email, password: 'SecurePass123!');

        final user = repository.getCurrentUser();

        expect(user, isNotNull);
        expect(user!.email, equals(email));
      });

      test('should return null after sign out', () async {
        await repository.signUp(
          email: 'test@example.com',
          password: 'SecurePass123!',
        );
        await repository.signOut();

        final user = repository.getCurrentUser();

        expect(user, isNull);
      });
    });

    group('isAuthenticated', () {
      test('should return false when not authenticated', () {
        expect(repository.isAuthenticated, isFalse);
      });

      test('should return true after successful sign up', () async {
        await repository.signUp(
          email: 'test@example.com',
          password: 'SecurePass123!',
        );

        expect(repository.isAuthenticated, isTrue);
      });

      test('should return false after sign out', () async {
        await repository.signUp(
          email: 'test@example.com',
          password: 'SecurePass123!',
        );
        await repository.signOut();

        expect(repository.isAuthenticated, isFalse);
      });
    });

    group('authStateChanges', () {
      test('should be a valid stream', () {
        // Verify authStateChanges is a stream we can listen to
        expect(repository.authStateChanges, isA<Stream<AppUser?>>());
      });

      test('should emit user when sign up is called', () async {
        const email = 'test@example.com';

        // Subscribe before action
        final futureUser = repository.authStateChanges
            .where((u) => u != null && u.email == email)
            .first
            .timeout(const Duration(seconds: 2));

        // Trigger sign up
        await repository.signUp(email: email, password: 'SecurePass123!');

        // Verify emission
        final user = await futureUser;
        expect(user!.email, equals(email));
      });

      test('should emit null when sign out is called', () async {
        // Sign up first
        await repository.signUp(
          email: 'test@example.com',
          password: 'SecurePass123!',
        );

        // Subscribe before sign out - wait for null after the current user
        final futureNull = repository.authStateChanges
            .where((u) => u == null)
            .first
            .timeout(const Duration(seconds: 2));

        // Trigger sign out
        await repository.signOut();

        // Verify null emission
        final user = await futureNull;
        expect(user, isNull);
      });
    });
  });

  group('Edge Cases', () {
    test('should handle empty password', () async {
      final result = await repository.signUp(
        email: 'test@example.com',
        password: '',
      );

      expect(result.isFailure, isTrue);
      expect(result.error, equals(AuthError.weakPassword));
    });

    test('should handle email with only spaces', () async {
      final result = await repository.signUp(
        email: '   ',
        password: 'SecurePass123!',
      );

      expect(result.isFailure, isTrue);
      expect(result.error, equals(AuthError.invalidEmail));
    });

    test('should reset simulations after resetSimulations call', () async {
      repository.simulateNetworkError();
      repository.resetSimulations();

      final result = await repository.signInWithGoogle();

      expect(result.isSuccess, isTrue);
    });
  });
}
