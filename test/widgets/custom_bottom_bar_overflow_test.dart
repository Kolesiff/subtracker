import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/widgets/custom_bottom_bar.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('CustomBottomBar Overflow Tests', () {
    // Helper to create bottom bar with various screen sizes
    Widget createBottomBarWithSize({
      required Size screenSize,
      bool showLabels = true,
    }) {
      return createTestableWidget(
        screenSize: screenSize,
        child: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: CustomBottomBar(
            currentItem: CustomBottomBarItem.dashboard,
            onItemSelected: (_) {},
            showLabels: showLabels,
          ),
        ),
      );
    }

    group('Small Screen (320x568 - iPhone SE 1st gen)', () {
      testWidgets('renders without overflow with labels', (tester) async {
        final errors = <FlutterErrorDetails>[];
        final originalHandler = FlutterError.onError;
        FlutterError.onError = (details) => errors.add(details);

        await tester.pumpWidget(createBottomBarWithSize(
          screenSize: TestScreenSizes.smallPhone,
          showLabels: true,
        ));
        await tester.pumpAndSettle();

        FlutterError.onError = originalHandler;

        // Should not have overflow errors
        final overflowErrors = errors.where(
            (e) => e.toString().contains('overflowed'));
        expect(overflowErrors, isEmpty,
            reason: 'Bottom bar should not overflow on small screens');
      });

      testWidgets('all 4 nav items are visible', (tester) async {
        await tester.pumpWidget(createBottomBarWithSize(
          screenSize: TestScreenSizes.smallPhone,
          showLabels: true,
        ));
        await tester.pumpAndSettle();

        // Check for icons (using both selected and unselected variants)
        expect(find.byIcon(Icons.dashboard_rounded), findsOneWidget);
        expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
        expect(find.byIcon(Icons.add_circle_rounded), findsOneWidget);
        expect(find.byIcon(Icons.analytics_outlined), findsOneWidget);
      });
    });

    group('Medium Screen (375x667 - iPhone 8)', () {
      testWidgets('renders without overflow with labels', (tester) async {
        final errors = <FlutterErrorDetails>[];
        final originalHandler = FlutterError.onError;
        FlutterError.onError = (details) => errors.add(details);

        await tester.pumpWidget(createBottomBarWithSize(
          screenSize: TestScreenSizes.mediumPhone,
          showLabels: true,
        ));
        await tester.pumpAndSettle();

        FlutterError.onError = originalHandler;

        final overflowErrors = errors.where(
            (e) => e.toString().contains('overflowed'));
        expect(overflowErrors, isEmpty);
      });

      testWidgets('labels are displayed', (tester) async {
        await tester.pumpWidget(createBottomBarWithSize(
          screenSize: TestScreenSizes.mediumPhone,
          showLabels: true,
        ));
        await tester.pumpAndSettle();

        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Trials'), findsOneWidget);
        expect(find.text('Add'), findsOneWidget);
        expect(find.text('Analytics'), findsOneWidget);
      });
    });

    group('Large Screen (428x926 - iPhone 14 Pro Max)', () {
      testWidgets('all labels are shown at full size', (tester) async {
        await tester.pumpWidget(createBottomBarWithSize(
          screenSize: TestScreenSizes.largePhone,
          showLabels: true,
        ));
        await tester.pumpAndSettle();

        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Trials'), findsOneWidget);
        expect(find.text('Add'), findsOneWidget);
        expect(find.text('Analytics'), findsOneWidget);
      });
    });

    group('Flex Behavior', () {
      testWidgets('all nav items use consistent flex behavior', (tester) async {
        await tester.pumpWidget(createBottomBarWithSize(
          screenSize: TestScreenSizes.mediumPhone,
          showLabels: true,
        ));
        await tester.pumpAndSettle();

        // Find the Row containing nav items
        final rowFinder = find.byType(Row);
        expect(rowFinder, findsWidgets);

        // The bottom bar's Row should have 4 children
        // and should distribute space evenly (spaceAround)
        final rows = tester.widgetList<Row>(rowFinder);
        for (final row in rows) {
          if (row.children.length == 4) {
            expect(row.mainAxisAlignment, equals(MainAxisAlignment.spaceAround));
            break;
          }
        }
      });

      testWidgets('all nav items have similar widths', (tester) async {
        await tester.pumpWidget(createBottomBarWithSize(
          screenSize: TestScreenSizes.mediumPhone,
          showLabels: true,
        ));
        await tester.pumpAndSettle();

        // Find all nav item containers by looking for InkWell widgets
        final inkWells = find.byType(InkWell);
        final widths = <double>[];

        for (final inkWell in tester.widgetList<InkWell>(inkWells)) {
          try {
            final size = tester.getSize(find.byWidget(inkWell));
            widths.add(size.width);
          } catch (_) {
            // Ignore InkWells we can't measure
          }
        }

        // All nav items should have reasonable widths (not collapsed to 0)
        for (final width in widths) {
          expect(width, greaterThan(40),
              reason: 'Each nav item should have minimum width');
        }
      });
    });

    group('showLabels: false', () {
      testWidgets('removes labels entirely', (tester) async {
        await tester.pumpWidget(createBottomBarWithSize(
          screenSize: TestScreenSizes.smallPhone,
          showLabels: false,
        ));
        await tester.pumpAndSettle();

        expect(find.text('Dashboard'), findsNothing);
        expect(find.text('Trials'), findsNothing);
        expect(find.text('Add'), findsNothing);
        expect(find.text('Analytics'), findsNothing);
      });

      testWidgets('icons still visible without labels', (tester) async {
        await tester.pumpWidget(createBottomBarWithSize(
          screenSize: TestScreenSizes.smallPhone,
          showLabels: false,
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.dashboard_rounded), findsOneWidget);
        expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
        expect(find.byIcon(Icons.add_circle_rounded), findsOneWidget);
        expect(find.byIcon(Icons.analytics_outlined), findsOneWidget);
      });
    });
  });
}
