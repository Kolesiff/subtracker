import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:subtracker/presentation/login_screen/widgets/social_login_widget.dart';

void main() {
  Widget buildTestableWidget({required Function(String) onSocialLogin}) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          home: Scaffold(
            body: SocialLoginWidget(onSocialLogin: onSocialLogin),
          ),
        );
      },
    );
  }

  group('SocialLoginWidget', () {
    group('Rendering', () {
      testWidgets('renders Google sign in button', (tester) async {
        await tester.pumpWidget(buildTestableWidget(onSocialLogin: (_) {}));
        await tester.pumpAndSettle();

        expect(find.text('Continue with Google'), findsOneWidget);
        expect(find.byIcon(Icons.g_mobiledata), findsOneWidget);
      });

      testWidgets('renders Apple sign in button', (tester) async {
        await tester.pumpWidget(buildTestableWidget(onSocialLogin: (_) {}));
        await tester.pumpAndSettle();

        expect(find.text('Continue with Apple'), findsOneWidget);
        expect(find.byIcon(Icons.apple), findsOneWidget);
      });

      testWidgets('renders both buttons as OutlinedButtons', (tester) async {
        await tester.pumpWidget(buildTestableWidget(onSocialLogin: (_) {}));
        await tester.pumpAndSettle();

        expect(find.byType(OutlinedButton), findsNWidgets(2));
      });
    });

    group('Callbacks', () {
      testWidgets('Google button triggers callback with "Google"', (tester) async {
        String? receivedProvider;
        await tester.pumpWidget(buildTestableWidget(
          onSocialLogin: (provider) => receivedProvider = provider,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue with Google'));
        await tester.pumpAndSettle();

        expect(receivedProvider, equals('Google'));
      });

      testWidgets('Apple button triggers callback with "Apple"', (tester) async {
        String? receivedProvider;
        await tester.pumpWidget(buildTestableWidget(
          onSocialLogin: (provider) => receivedProvider = provider,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue with Apple'));
        await tester.pumpAndSettle();

        expect(receivedProvider, equals('Apple'));
      });

      testWidgets('callback is invoked exactly once per tap', (tester) async {
        int callCount = 0;
        await tester.pumpWidget(buildTestableWidget(
          onSocialLogin: (_) => callCount++,
        ));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue with Google'));
        await tester.pumpAndSettle();

        expect(callCount, equals(1));

        await tester.tap(find.text('Continue with Apple'));
        await tester.pumpAndSettle();

        expect(callCount, equals(2));
      });
    });

    group('Accessibility', () {
      testWidgets('buttons have semantic labels', (tester) async {
        await tester.pumpWidget(buildTestableWidget(onSocialLogin: (_) {}));
        await tester.pumpAndSettle();

        // Both buttons should be tappable and have text labels
        final googleButton = find.widgetWithText(OutlinedButton, 'Continue with Google');
        final appleButton = find.widgetWithText(OutlinedButton, 'Continue with Apple');

        expect(googleButton, findsOneWidget);
        expect(appleButton, findsOneWidget);
      });
    });
  });
}
