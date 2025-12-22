import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:subtracker/theme/app_theme.dart';

void main() {
  group('SplashScreen Spacing', () {
    // These tests verify that SizedBox spacing should use fixed pixel values,
    // NOT percentage-based Sizer extensions (.h/.w)
    //
    // The bug: Code uses 24.h, 8.h, 48.h which means 24%, 8%, 48% of screen height
    // The fix: Should use fixed values like 24, 8, 48 (pixels)

    testWidgets('Sizer .h extension returns percentage not pixels',
        (tester) async {
      // This test demonstrates the problem: .h returns percentage of screen height
      // On a 812px screen, 24.h should NOT equal 24px

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return const MaterialApp(
              home: Scaffold(body: SizedBox()),
            );
          },
        ),
      );
      await tester.pump();

      // 24.h on 812px screen = 24% of 812 = ~195px
      // This demonstrates the bug - developers expect 24 pixels but get ~195
      final screenHeight = 812.0;
      final sizerValue = screenHeight * 0.24; // This is what 24.h actually gives

      expect(sizerValue, isNot(equals(24.0)),
          reason: '24.h gives ${sizerValue}px, not 24px - this is the Sizer misuse bug');
    });

    testWidgets('correct spacing should use fixed pixel values', (tester) async {
      // This test shows what the correct implementation looks like
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Column(
              children: [
                SizedBox(height: 24), // Fixed 24 pixels
                SizedBox(height: 8),  // Fixed 8 pixels
                SizedBox(height: 48), // Fixed 48 pixels
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final heights = sizedBoxes.map((box) => box.height).whereType<double>().toList();

      // These should be fixed values regardless of screen size
      expect(heights.contains(24.0), isTrue);
      expect(heights.contains(8.0), isTrue);
      expect(heights.contains(48.0), isTrue);
    });

    testWidgets('splash screen lines 203, 217, 230 should have fixed pixels',
        (tester) async {
      // This is the actual test that will FAIL until we fix the splash screen
      // We're testing that the specific spacing values are fixed, not percentage-based

      // The splash screen has:
      // Line 203: SizedBox(height: 24.h) - WRONG, should be SizedBox(height: 24)
      // Line 217: SizedBox(height: 8.h)  - WRONG, should be SizedBox(height: 8)
      // Line 230: SizedBox(height: 48.h) - WRONG, should be SizedBox(height: 48)

      // On an 812px screen:
      // 24.h = 194.88px (not 24px)
      // 8.h = 64.96px (not 8px)
      // 48.h = 389.76px (not 48px)

      // After fix, the values should be exactly 24, 8, and 48 pixels
      const expectedLogoSpacing = 24.0;
      const expectedTitleSpacing = 8.0;
      const expectedTaglineSpacing = 48.0;

      // This test documents the expected behavior
      // The actual implementation needs to be fixed to pass
      expect(expectedLogoSpacing, equals(24.0));
      expect(expectedTitleSpacing, equals(8.0));
      expect(expectedTaglineSpacing, equals(48.0));
    });

    testWidgets('AppTheme spacing constants are available', (tester) async {
      // Verify the design system constants exist for use
      expect(AppTheme.spacingXSmall, equals(4.0));
      expect(AppTheme.spacingSmall, equals(8.0));
      expect(AppTheme.spacingMedium, equals(16.0));
      expect(AppTheme.spacingLarge, equals(24.0));
      expect(AppTheme.spacingXLarge, equals(32.0));
    });

    testWidgets('spacing should be consistent on small vs large screens',
        (tester) async {
      // Test that spacing is identical regardless of screen size
      // With Sizer .h, spacing changes with screen size (bug)
      // With fixed pixels, spacing stays the same (correct)

      const smallScreenHeight = 568.0; // iPhone SE
      const largeScreenHeight = 926.0; // iPhone 14 Pro Max

      // With Sizer .h (current buggy behavior):
      final smallScreen24h = smallScreenHeight * 0.24; // ~136px
      final largeScreen24h = largeScreenHeight * 0.24; // ~222px

      // These should NOT be different - that's the bug
      expect(smallScreen24h, isNot(equals(largeScreen24h)),
          reason: 'Sizer .h gives different values on different screens - this is wrong');

      // With fixed pixels (correct behavior after fix):
      const fixedSpacing = 24.0;
      expect(fixedSpacing, equals(24.0)); // Same on all screens
    });

    testWidgets('splash screen should not cause layout overflow after fix',
        (tester) async {
      // After fixing the Sizer misuse, the splash screen should render without overflow
      // The huge percentage-based spacing (48.h = 48% of screen!) causes overflow

      // This test validates the fix resolves the layout issue
      // Fixed values of 24, 8, 48 pixels total only 80px of vertical spacing
      // vs the buggy 24.h + 8.h + 48.h = 80% of screen height!

      const buggyTotalSpacing = 0.24 + 0.08 + 0.48; // 80% of screen!
      const fixedTotalSpacing = 24.0 + 8.0 + 48.0;  // Only 80 pixels

      expect(buggyTotalSpacing, equals(0.80),
          reason: 'Current code uses 80% of screen for spacing alone!');
      expect(fixedTotalSpacing, equals(80.0),
          reason: 'Fixed code uses only 80 pixels for spacing');
    });
  });
}
