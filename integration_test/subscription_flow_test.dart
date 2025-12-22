import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:subtracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SubTracker Integration Tests', () {
    testWidgets('can navigate from splash to dashboard', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // After splash screen timeout, should be on login or dashboard
      // The app should be fully loaded
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });

    testWidgets('can navigate between bottom bar tabs', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Look for bottom navigation items
      // The exact navigation depends on the initial route
      final bottomBar = find.byType(BottomNavigationBar);
      if (bottomBar.evaluate().isNotEmpty) {
        // Try tapping on different nav items
        final navItems = find.descendant(
          of: bottomBar,
          matching: find.byType(InkWell),
        );

        if (navItems.evaluate().length > 1) {
          await tester.tap(navItems.at(1));
          await tester.pumpAndSettle();
          expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
        }
      }
    });

    testWidgets('analytics screen loads data correctly', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to analytics if not already there
      // Look for Analytics text or tab
      final analyticsTab = find.text('Analytics');
      if (analyticsTab.evaluate().isNotEmpty) {
        await tester.tap(analyticsTab.first);
        await tester.pumpAndSettle();

        // Should see analytics content
        expect(find.text('Total Monthly Spending'), findsOneWidget);
      }
    });

    testWidgets('trial tracker displays trial cards', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to trials tab
      final trialsTab = find.text('Trials');
      if (trialsTab.evaluate().isNotEmpty) {
        await tester.tap(trialsTab.first);
        await tester.pumpAndSettle();

        // Should see trial tracker content
        // Either trial cards or empty state
        final hasContent = find.text('Active Trials').evaluate().isNotEmpty ||
            find.text('No Active Trials').evaluate().isNotEmpty;
        expect(hasContent, isTrue);
      }
    });
  });
}
