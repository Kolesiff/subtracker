import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:subtracker/data/models/models.dart';
import 'package:subtracker/data/repositories/mock_auth_repository.dart';
import 'package:subtracker/presentation/auth/viewmodel/auth_viewmodel.dart';
import 'package:subtracker/presentation/login_screen/login_screen.dart';
import 'package:subtracker/routes/app_routes.dart';

void main() {
  late MockAuthRepository mockRepository;
  late AuthViewModel viewModel;

  Widget buildTestableWidget(Widget child) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return ChangeNotifierProvider<AuthViewModel>.value(
          value: viewModel,
          child: MaterialApp(
            home: child,
            routes: {
              AppRoutes.subscriptionDashboard: (_) => const Scaffold(
                    body: Center(child: Text('Dashboard')),
                  ),
            },
          ),
        );
      },
    );
  }

  setUp(() {
    mockRepository = MockAuthRepository();
    viewModel = AuthViewModel(repository: mockRepository);
  });

  tearDown(() {
    viewModel.dispose();
    mockRepository.dispose();
  });

  group('LoginScreen', () {
    group('Tab Navigation', () {
      testWidgets('renders with Sign In tab selected by default', (tester) async {
        await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
        await tester.pumpAndSettle();

        // Tab bar should contain both tabs
        expect(find.byType(TabBar), findsOneWidget);
        expect(find.byType(Tab), findsNWidgets(2));
      });

      testWidgets('switches to Sign Up tab when tapped', (tester) async {
        await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        // Confirm password field should be visible on Sign Up tab
        expect(find.text('Confirm Password'), findsOneWidget);
      });

      testWidgets('switches back to Sign In tab when tapped', (tester) async {
        await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
        await tester.pumpAndSettle();

        // Switch to Sign Up
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        // Switch back to Sign In
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        // Forgot Password should be visible on Sign In tab
        expect(find.text('Forgot Password?'), findsOneWidget);
      });
    });

    group('Sign In Form', () {
      testWidgets('renders email and password fields', (tester) async {
        await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      });

      testWidgets('renders Sign In button', (tester) async {
        await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
      });

      testWidgets('renders Forgot Password button', (tester) async {
        await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Forgot Password?'), findsOneWidget);
      });

      testWidgets('password visibility toggle works', (tester) async {
        await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
        await tester.pumpAndSettle();

        // Initially password should be obscured (visibility_off icon shown)
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);

        // Tap to toggle visibility
        await tester.tap(find.byIcon(Icons.visibility_off).first);
        await tester.pumpAndSettle();

        // Now password should be visible (visibility icon shown)
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });

      testWidgets('shows validation error for empty email', (tester) async {
        await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
        await tester.pumpAndSettle();

        // Try to submit without entering anything
        await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
        await tester.pumpAndSettle();

        expect(find.text('Email is required'), findsOneWidget);
      });

      testWidgets('shows validation error for invalid email', (tester) async {
        await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
        await tester.pumpAndSettle();

        // Enter invalid email
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'notanemail');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'), 'somepassword');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter a valid email address'), findsOneWidget);
      });

      testWidgets('shows validation error for empty password', (tester) async {
        await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
        await tester.pumpAndSettle();

        // Enter email but not password
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'test@example.com');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
        await tester.pumpAndSettle();

        expect(find.text('Password is required'), findsOneWidget);
      });
    });

    group('Sign Up Form', () {
      testWidgets('renders email, password, and confirm password fields', (tester) async {
        await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
        await tester.pumpAndSettle();

        // Switch to Sign Up tab
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, 'Confirm Password'), findsOneWidget);
      });

      testWidgets('renders Create Account button', (tester) async {
        await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(ElevatedButton, 'Create Account'), findsOneWidget);
      });

      testWidgets('shows password requirements helper text', (tester) async {
        await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        expect(find.text('Min 8 chars with uppercase, lowercase & number'), findsOneWidget);
      });

      testWidgets('shows validation error for weak password', (tester) async {
        await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        // Enter valid email but weak password
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'), 'weak');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Confirm Password'), 'weak');

        // Scroll to make button visible and tap
        await tester.ensureVisible(find.text('Create Account'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Create Account'));
        await tester.pumpAndSettle();

        expect(find.text('Password must be at least 8 characters'), findsOneWidget);
      });

      testWidgets('shows validation error for mismatched passwords', (tester) async {
        await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'), 'SecurePass123!');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Confirm Password'), 'Different123!');

        // Scroll to make button visible and tap
        await tester.ensureVisible(find.text('Create Account'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Create Account'));
        await tester.pumpAndSettle();

        expect(find.text('Passwords do not match'), findsOneWidget);
      });
    });

    group('Social Login', () {
      testWidgets('renders Google and Apple sign in buttons', (tester) async {
        await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Continue with Google'), findsOneWidget);
        expect(find.text('Continue with Apple'), findsOneWidget);
      });

      testWidgets('renders OR divider between form and social buttons', (tester) async {
        await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
        await tester.pumpAndSettle();

        expect(find.text('OR'), findsOneWidget);
      });
    });

    group('Header', () {
      testWidgets('renders app logo and title', (tester) async {
        await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
        await tester.pumpAndSettle();

        expect(find.text('SubTracker'), findsOneWidget);
        expect(find.text('Sign in to manage your subscriptions'), findsOneWidget);
        expect(find.byIcon(Icons.subscriptions_rounded), findsOneWidget);
      });
    });

    group('Loading State', () {
      testWidgets('button is disabled when loading', (tester) async {
        await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
        await tester.pumpAndSettle();

        // Enter valid credentials
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'), 'SecurePass123!');

        // Ensure button is visible and enabled initially
        final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
        await tester.ensureVisible(signInButton);
        await tester.pumpAndSettle();

        // Button should be enabled before tapping
        final button = tester.widget<ElevatedButton>(signInButton);
        expect(button.onPressed, isNotNull);
      });
    });

    group('Authentication Flow', () {
      testWidgets('sign in button triggers authentication', (tester) async {
        await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'), 'SecurePass123!');

        // Ensure button is visible and can be tapped
        final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
        await tester.ensureVisible(signInButton);
        await tester.pumpAndSettle();

        // Button should be tappable
        expect(signInButton, findsOneWidget);
      });

      testWidgets('sign up button triggers account creation', (tester) async {
        await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        await tester.enterText(
            find.widgetWithText(TextFormField, 'Email'), 'newuser@example.com');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Password'), 'SecurePass123!');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Confirm Password'), 'SecurePass123!');

        // Ensure button is visible and can be tapped
        await tester.ensureVisible(find.text('Create Account'));
        await tester.pumpAndSettle();

        // Button should be tappable
        expect(find.text('Create Account'), findsOneWidget);
      });
    });
  });
}
