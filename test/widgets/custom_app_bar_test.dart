import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/widgets/custom_app_bar.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('CustomAppBar Widget Tests', () {
    group('Standard Style', () {
      testWidgets('renders AppBar with standard style', (tester) async {
        await tester.pumpWidget(createTestableWidget(
          child: Scaffold(
            appBar: const CustomAppBar(
              title: 'Test Title',
              style: CustomAppBarStyle.standard,
            ),
            body: const SizedBox(),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Test Title'), findsOneWidget);
      });

      testWidgets('renders without console errors', (tester) async {
        final errors = <FlutterErrorDetails>[];
        final originalHandler = FlutterError.onError;
        FlutterError.onError = (details) => errors.add(details);

        await tester.pumpWidget(createTestableWidget(
          child: Scaffold(
            appBar: const CustomAppBar(
              title: 'Test Title',
              style: CustomAppBarStyle.standard,
            ),
            body: const SizedBox(),
          ),
        ));
        await tester.pumpAndSettle();

        FlutterError.onError = originalHandler;

        final sliverErrors = errors.where((e) =>
            e.toString().contains('RenderBox') ||
            e.toString().contains('Sliver'));
        expect(sliverErrors, isEmpty);
      });
    });

    group('Large Style', () {
      testWidgets('large style renders without RenderBox/Sliver errors',
          (tester) async {
        final errors = <FlutterErrorDetails>[];
        final originalHandler = FlutterError.onError;
        FlutterError.onError = (details) => errors.add(details);

        // The issue: CustomAppBar.large returns SliverAppBar
        // but Scaffold.appBar expects PreferredSizeWidget
        await tester.pumpWidget(createTestableWidget(
          child: Scaffold(
            appBar: const CustomAppBar(
              title: 'Dashboard',
              style: CustomAppBarStyle.large,
            ),
            body: const SizedBox(),
          ),
        ));
        await tester.pumpAndSettle();

        FlutterError.onError = originalHandler;

        // Should NOT have RenderBox/Sliver mismatch errors
        final sliverErrors = errors.where((e) =>
            e.toString().contains('RenderBox') ||
            e.toString().contains('Sliver'));
        expect(sliverErrors, isEmpty,
            reason: 'Large style should not cause RenderBox/Sliver errors');
      });

      testWidgets('large style returns AppBar not SliverAppBar', (tester) async {
        await tester.pumpWidget(createTestableWidget(
          child: Scaffold(
            appBar: const CustomAppBar(
              title: 'Dashboard',
              style: CustomAppBarStyle.large,
            ),
            body: const SizedBox(),
          ),
        ));
        await tester.pumpAndSettle();

        // Should find AppBar, not SliverAppBar when used in Scaffold.appBar
        expect(find.byType(AppBar), findsOneWidget);
        // SliverAppBar should NOT be present in this context
        expect(find.byType(SliverAppBar), findsNothing);
      });

      testWidgets('large style displays title correctly', (tester) async {
        await tester.pumpWidget(createTestableWidget(
          child: Scaffold(
            appBar: const CustomAppBar(
              title: 'Dashboard',
              style: CustomAppBarStyle.large,
            ),
            body: const SizedBox(),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.text('Dashboard'), findsOneWidget);
      });

      testWidgets('preferredSize returns correct height for large style',
          (tester) async {
        const appBar = CustomAppBar(
          title: 'Test',
          style: CustomAppBarStyle.large,
        );

        expect(appBar.preferredSize.height, equals(112.0));
      });

      testWidgets('large style has taller height than standard', (tester) async {
        const standardAppBar = CustomAppBar(
          title: 'Standard',
          style: CustomAppBarStyle.standard,
        );

        const largeAppBar = CustomAppBar(
          title: 'Large',
          style: CustomAppBarStyle.large,
        );

        expect(largeAppBar.preferredSize.height,
            greaterThan(standardAppBar.preferredSize.height));
      });
    });

    group('Search Style', () {
      testWidgets('search style shows search field', (tester) async {
        await tester.pumpWidget(createTestableWidget(
          child: Scaffold(
            appBar: CustomAppBar(
              style: CustomAppBarStyle.search,
              onSearchChanged: (query) {},
            ),
            body: const SizedBox(),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsOneWidget);
        expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      });

      testWidgets('search callback is invoked on text change', (tester) async {
        String? capturedQuery;
        await tester.pumpWidget(createTestableWidget(
          child: Scaffold(
            appBar: CustomAppBar(
              style: CustomAppBarStyle.search,
              onSearchChanged: (query) => capturedQuery = query,
            ),
            body: const SizedBox(),
          ),
        ));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Netflix');
        expect(capturedQuery, equals('Netflix'));
      });
    });

    group('Transparent Style', () {
      testWidgets('transparent style has transparent background',
          (tester) async {
        await tester.pumpWidget(createTestableWidget(
          child: Scaffold(
            appBar: const CustomAppBar(
              style: CustomAppBarStyle.transparent,
            ),
            body: const SizedBox(),
          ),
        ));
        await tester.pumpAndSettle();

        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.backgroundColor, equals(Colors.transparent));
      });
    });

    group('Back Button', () {
      testWidgets('back button shows when Navigator can pop', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: const CustomAppBar(
                      title: 'Detail',
                      automaticallyImplyLeading: true,
                    ),
                    body: const SizedBox(),
                  ),
                ),
              ),
              child: const Text('Navigate'),
            ),
          ),
        ));

        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      });

      testWidgets('custom onBackPressed callback is invoked', (tester) async {
        bool wasPressed = false;
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: CustomAppBar(
                      title: 'Detail',
                      onBackPressed: () => wasPressed = true,
                    ),
                    body: const SizedBox(),
                  ),
                ),
              ),
              child: const Text('Navigate'),
            ),
          ),
        ));

        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.arrow_back_rounded));
        await tester.pumpAndSettle();

        expect(wasPressed, isTrue);
      });
    });

    group('Actions', () {
      testWidgets('actions are rendered correctly', (tester) async {
        await tester.pumpWidget(createTestableWidget(
          child: Scaffold(
            appBar: CustomAppBar(
              title: 'Test',
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {},
                ),
              ],
            ),
            body: const SizedBox(),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.settings), findsOneWidget);
      });
    });
  });
}
