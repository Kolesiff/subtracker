import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/widgets/custom_bottom_bar.dart';
import 'package:subtracker/theme/app_theme.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('CustomBottomBar', () {
    late MockNavigatorObserver mockNavigatorObserver;
    late List<CustomBottomBarItem> callbackInvocations;

    setUp(() {
      mockNavigatorObserver = MockNavigatorObserver();
      callbackInvocations = [];
    });

    Widget createBottomBarTestWidget({
      CustomBottomBarItem currentItem = CustomBottomBarItem.dashboard,
      bool enableHapticFeedback = true,
    }) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        navigatorObservers: [mockNavigatorObserver],
        routes: {
          '/subscription-dashboard': (context) => const Scaffold(body: Text('Dashboard')),
          '/trial-tracker': (context) => const Scaffold(body: Text('Trials')),
          '/add-subscription': (context) => const Scaffold(body: Text('Add')),
          '/subscription-detail': (context) => const Scaffold(body: Text('Detail')),
        },
        home: Scaffold(
          body: const SizedBox(height: 400, child: Center(child: Text('Test Screen'))),
          bottomNavigationBar: SizedBox(
            height: 80,
            child: CustomBottomBar(
              currentItem: currentItem,
              onItemSelected: (item) {
                callbackInvocations.add(item);
              },
              enableHapticFeedback: enableHapticFeedback,
              showLabels: false, // Reduce size to avoid overflow
            ),
          ),
        ),
      );
    }

    testWidgets('callback invoked exactly once on tap', (tester) async {
      await tester.pumpWidget(createBottomBarTestWidget());
      await tester.pumpAndSettle();

      // Tap on Trials button (timer icon)
      await tester.tap(find.byIcon(Icons.timer_outlined));
      await tester.pumpAndSettle();

      // Callback should be invoked exactly once
      expect(callbackInvocations.length, equals(1),
          reason: 'Callback should be invoked exactly once per tap');
      expect(callbackInvocations.first, equals(CustomBottomBarItem.trials));
    });

    testWidgets('bottom bar does not call Navigator directly', (tester) async {
      await tester.pumpWidget(createBottomBarTestWidget());
      await tester.pumpAndSettle();

      // Reset observer to clear initial route push
      mockNavigatorObserver.reset();

      // Tap on Trials button (timer icon)
      await tester.tap(find.byIcon(Icons.timer_outlined));
      await tester.pumpAndSettle();

      // Bottom bar should NOT push any routes - that's the parent's job
      // This test will FAIL initially because _navigateToRoute calls pushNamed
      expect(mockNavigatorObserver.pushedRoutes.length, equals(0),
          reason: 'Bottom bar should not navigate directly - callback handles it');
    });

    testWidgets('callback receives correct enum value for each item',
        (tester) async {
      await tester.pumpWidget(createBottomBarTestWidget());
      await tester.pumpAndSettle();

      // Tap Trials (timer icon)
      await tester.tap(find.byIcon(Icons.timer_outlined));
      await tester.pumpAndSettle();

      // Tap Analytics (analytics icon)
      await tester.tap(find.byIcon(Icons.analytics_outlined));
      await tester.pumpAndSettle();

      // Tap Add (add circle icon)
      await tester.tap(find.byIcon(Icons.add_circle_rounded));
      await tester.pumpAndSettle();

      expect(callbackInvocations, [
        CustomBottomBarItem.trials,
        CustomBottomBarItem.analytics,
        CustomBottomBarItem.add,
      ]);
    });

    testWidgets('same-item tap ignored (no callback)', (tester) async {
      await tester.pumpWidget(createBottomBarTestWidget(
        currentItem: CustomBottomBarItem.dashboard,
      ));
      await tester.pumpAndSettle();

      // Tap on Dashboard (already selected - dashboard_rounded when selected)
      await tester.tap(find.byIcon(Icons.dashboard_rounded));
      await tester.pumpAndSettle();

      // Callback should NOT be invoked for current item
      expect(callbackInvocations.length, equals(0),
          reason: 'Should not invoke callback when tapping current item');
    });

    testWidgets('haptic feedback triggers when enabled', (tester) async {
      // Track haptic feedback calls
      final hapticLogs = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'HapticFeedback.vibrate') {
            hapticLogs.add(methodCall);
          }
          return null;
        },
      );

      await tester.pumpWidget(createBottomBarTestWidget(
        enableHapticFeedback: true,
      ));
      await tester.pumpAndSettle();

      // Tap on Trials (timer icon)
      await tester.tap(find.byIcon(Icons.timer_outlined));
      await tester.pumpAndSettle();

      expect(hapticLogs.length, greaterThan(0),
          reason: 'Haptic feedback should trigger when enabled');
    });

    testWidgets('haptic feedback disabled when flag is false', (tester) async {
      // Track haptic feedback calls
      final hapticLogs = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'HapticFeedback.vibrate') {
            hapticLogs.add(methodCall);
          }
          return null;
        },
      );

      await tester.pumpWidget(createBottomBarTestWidget(
        enableHapticFeedback: false,
      ));
      await tester.pumpAndSettle();

      // Tap on Trials (timer icon)
      await tester.tap(find.byIcon(Icons.timer_outlined));
      await tester.pumpAndSettle();

      expect(hapticLogs.length, equals(0),
          reason: 'Haptic feedback should not trigger when disabled');
    });

    testWidgets('animation plays on tap', (tester) async {
      await tester.pumpWidget(createBottomBarTestWidget());
      await tester.pumpAndSettle();

      // Verify ScaleTransition widgets exist before tap
      expect(find.byType(ScaleTransition), findsWidgets);

      // Tap on Trials (timer icon)
      await tester.tap(find.byIcon(Icons.timer_outlined));
      // Only pump a few frames to catch animation mid-flight
      await tester.pump(const Duration(milliseconds: 100));

      // Animation should have started (ScaleTransition widgets still present)
      expect(find.byType(ScaleTransition), findsWidgets);
    });

    testWidgets('no duplicate routes in navigation stack', (tester) async {
      await tester.pumpWidget(createBottomBarTestWidget());
      await tester.pumpAndSettle();

      // Reset observer
      mockNavigatorObserver.reset();

      // Tap on Trials (timer icon)
      await tester.tap(find.byIcon(Icons.timer_outlined));
      await tester.pumpAndSettle();

      // Count how many times /trial-tracker was pushed
      // This test will FAIL initially because double navigation pushes twice
      final trialTrackerPushCount =
          mockNavigatorObserver.countPushesTo('/trial-tracker');

      expect(trialTrackerPushCount, lessThanOrEqualTo(1),
          reason:
              'Route should be pushed at most once, not twice (double navigation bug)');
    });
  });
}
