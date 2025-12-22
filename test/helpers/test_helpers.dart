import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/data/providers/app_providers.dart';
import 'package:subtracker/theme/app_theme.dart';

/// Creates a testable MaterialApp wrapper with required providers and theme.
/// Use this to wrap widgets under test that need the app's context.
Widget createTestableWidget({
  required Widget child,
  bool useDarkTheme = false,
  Size screenSize = const Size(375, 812), // iPhone X size default
  NavigatorObserver? navigatorObserver,
  List<NavigatorObserver>? navigatorObservers,
}) {
  final observers = <NavigatorObserver>[];
  if (navigatorObserver != null) observers.add(navigatorObserver);
  if (navigatorObservers != null) observers.addAll(navigatorObservers);

  return MediaQuery(
    data: MediaQueryData(size: screenSize),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: useDarkTheme ? AppTheme.darkTheme : AppTheme.lightTheme,
      navigatorObservers: observers,
      home: child,
    ),
  );
}

/// Creates a testable widget with full app providers.
/// Use for integration-style widget tests that need repository access.
Widget createTestableWidgetWithProviders({
  required Widget child,
  bool useDarkTheme = false,
  Size screenSize = const Size(375, 812),
  NavigatorObserver? navigatorObserver,
}) {
  return AppProviders(
    child: createTestableWidget(
      child: child,
      useDarkTheme: useDarkTheme,
      screenSize: screenSize,
      navigatorObserver: navigatorObserver,
    ),
  );
}

/// Mock navigator observer to track navigation calls.
class MockNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];
  final List<Route<dynamic>> poppedRoutes = [];
  final List<Route<dynamic>> replacedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    poppedRoutes.add(route);
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) replacedRoutes.add(newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  void reset() {
    pushedRoutes.clear();
    poppedRoutes.clear();
    replacedRoutes.clear();
  }

  /// Returns the number of times a specific route was pushed.
  int countPushesTo(String routeName) {
    return pushedRoutes
        .where((route) => route.settings.name == routeName)
        .length;
  }
}

/// Finds a SizedBox with specific height in the widget tree.
/// Returns the actual height value for assertion.
double? findSizedBoxHeight(WidgetTester tester, {int index = 0}) {
  final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
  final list = sizedBoxes.toList();
  if (index < list.length) {
    return list[index].height;
  }
  return null;
}

/// Finds all SizedBox widgets and returns their heights.
List<double?> findAllSizedBoxHeights(WidgetTester tester) {
  final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
  return sizedBoxes.map((box) => box.height).toList();
}

/// Extension to easily pump a widget with frame settling.
extension WidgetTesterExtensions on WidgetTester {
  /// Pumps the widget and settles all animations.
  Future<void> pumpAndSettleWidget(Widget widget) async {
    await pumpWidget(widget);
    await pumpAndSettle();
  }
}

/// Screen size presets for testing responsive layouts.
class TestScreenSizes {
  static const Size smallPhone = Size(320, 568); // iPhone SE 1st gen
  static const Size mediumPhone = Size(375, 667); // iPhone 8
  static const Size largePhone = Size(428, 926); // iPhone 14 Pro Max
  static const Size tablet = Size(768, 1024); // iPad Mini
}
