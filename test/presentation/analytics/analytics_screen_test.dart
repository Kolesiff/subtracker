import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:subtracker/data/models/models.dart';
import 'package:subtracker/data/repositories/repositories.dart';
import 'package:subtracker/presentation/analytics/analytics_screen.dart';
import 'package:subtracker/presentation/analytics/viewmodel/analytics_viewmodel.dart';
import 'package:subtracker/theme/app_theme.dart';
import 'package:subtracker/routes/app_routes.dart';

/// Mock subscription repository for widget testing
class MockSubscriptionRepository implements SubscriptionRepository {
  List<Subscription> subscriptionsToReturn = [];
  bool shouldThrow = false;

  @override
  Future<List<Subscription>> getSubscriptions() async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (shouldThrow) throw Exception('Test error');
    return subscriptionsToReturn;
  }

  @override
  Future<Subscription?> getSubscription(String id) async => null;
  @override
  Future<void> addSubscription(Subscription subscription) async {}
  @override
  Future<void> updateSubscription(Subscription subscription) async {}
  @override
  Future<void> deleteSubscription(String id) async {}
  @override
  Future<List<Subscription>> getExpiringSoon({int withinDays = 7}) async => [];
  @override
  Future<List<Subscription>> getByCategory(SubscriptionCategory category) async => [];
  @override
  Future<List<Subscription>> getByStatus(SubscriptionStatus status) async => [];
  @override
  Future<List<Subscription>> search(String query) async => [];
  @override
  Future<List<BillingHistory>> getBillingHistory(String subscriptionId) async => [];
  @override
  Future<void> addBillingRecord(BillingHistory record) async {}
}

/// Mock trial repository for widget testing
class MockTrialRepository implements TrialRepository {
  List<Trial> trialsToReturn = [];
  bool shouldThrow = false;

  @override
  Future<List<Trial>> getTrials() async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (shouldThrow) throw Exception('Test error');
    return trialsToReturn;
  }

  @override
  Future<Trial?> getTrial(int id) async => null;
  @override
  Future<void> addTrial(Trial trial) async {}
  @override
  Future<void> updateTrial(Trial trial) async {}
  @override
  Future<void> deleteTrial(int id) async {}
  @override
  Future<List<Trial>> getByUrgency(UrgencyLevel level) async => [];
  @override
  Future<List<Trial>> getByCategory(SubscriptionCategory category) async => [];
  @override
  Future<List<Trial>> getCriticalTrials() async => [];
  @override
  Future<void> cancelTrial(int id) async {}
}

void main() {
  late MockSubscriptionRepository subscriptionRepo;
  late MockTrialRepository trialRepo;

  setUp(() {
    subscriptionRepo = MockSubscriptionRepository();
    trialRepo = MockTrialRepository();
  });

  Widget createTestWidget({bool useDarkTheme = false}) {
    final viewModel = AnalyticsViewModel(
      subscriptionRepository: subscriptionRepo,
      trialRepository: trialRepo,
    );

    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: useDarkTheme ? AppTheme.darkTheme : AppTheme.lightTheme,
          routes: {
            AppRoutes.subscriptionDashboard: (_) => const Scaffold(body: Text('Dashboard')),
            AppRoutes.trialTracker: (_) => const Scaffold(body: Text('Trials')),
            AppRoutes.addSubscription: (_) => const Scaffold(body: Text('Add')),
          },
          home: ChangeNotifierProvider<AnalyticsViewModel>.value(
            value: viewModel,
            child: const AnalyticsScreen(),
          ),
        );
      },
    );
  }

  group('AnalyticsScreen - Loading State', () {
    testWidgets('hides loading indicator after data loads', (tester) async {
      subscriptionRepo.subscriptionsToReturn = [_createSubscription('1')];
      trialRepo.trialsToReturn = [];

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('AnalyticsScreen - Error State', () {
    testWidgets('shows error message on failure', (tester) async {
      subscriptionRepo.shouldThrow = true;

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Failed to load analytics data'), findsOneWidget);
    });

    testWidgets('shows retry button on error', (tester) async {
      subscriptionRepo.shouldThrow = true;

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('retry button reloads data', (tester) async {
      subscriptionRepo.shouldThrow = true;

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Now fix the repository
      subscriptionRepo.shouldThrow = false;
      subscriptionRepo.subscriptionsToReturn = [_createSubscription('1', cost: 15.99)];
      trialRepo.trialsToReturn = [];

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Should now show the content (may appear twice in overview and mini stats)
      expect(find.text('\$15.99'), findsAtLeastNWidgets(1));
    });
  });

  group('AnalyticsScreen - Content Display', () {
    testWidgets('displays spending overview card', (tester) async {
      subscriptionRepo.subscriptionsToReturn = [
        _createSubscription('1', cost: 25.50),
      ];
      trialRepo.trialsToReturn = [];

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Total Monthly Spending'), findsOneWidget);
      // Value may appear in both overview card and mini stats
      expect(find.text('\$25.50'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays quick stats section', (tester) async {
      subscriptionRepo.subscriptionsToReturn = [
        _createSubscription('1'),
        _createSubscription('2'),
      ];
      trialRepo.trialsToReturn = [
        _createTrial(1, 5),
      ];

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Quick Stats'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      // "Trials" appears in quick stats and bottom nav
      expect(find.text('Trials'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays category breakdown section', (tester) async {
      subscriptionRepo.subscriptionsToReturn = [
        _createSubscription('1', category: SubscriptionCategory.entertainment),
      ];
      trialRepo.trialsToReturn = [];

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Spending by Category'), findsOneWidget);
      expect(find.text('Entertainment'), findsOneWidget);
    });

    testWidgets('shows empty message when no subscriptions', (tester) async {
      subscriptionRepo.subscriptionsToReturn = [];
      trialRepo.trialsToReturn = [];

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No subscription data available'), findsOneWidget);
    });
  });

  group('AnalyticsScreen - Theme Support', () {
    testWidgets('renders correctly in light theme', (tester) async {
      subscriptionRepo.subscriptionsToReturn = [_createSubscription('1')];
      trialRepo.trialsToReturn = [];

      await tester.pumpWidget(createTestWidget(useDarkTheme: false));
      await tester.pumpAndSettle();

      // Verify the screen renders without errors
      expect(find.byType(AnalyticsScreen), findsOneWidget);
      // "Analytics" appears in both AppBar and bottom nav
      expect(find.text('Analytics'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders correctly in dark theme', (tester) async {
      subscriptionRepo.subscriptionsToReturn = [_createSubscription('1')];
      trialRepo.trialsToReturn = [];

      await tester.pumpWidget(createTestWidget(useDarkTheme: true));
      await tester.pumpAndSettle();

      // Verify the screen renders without errors
      expect(find.byType(AnalyticsScreen), findsOneWidget);
      // "Analytics" appears in both AppBar and bottom nav
      expect(find.text('Analytics'), findsAtLeastNWidgets(1));
    });
  });

  group('AnalyticsScreen - AppBar', () {
    testWidgets('displays Analytics in AppBar', (tester) async {
      subscriptionRepo.subscriptionsToReturn = [];
      trialRepo.trialsToReturn = [];

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // "Analytics" appears in AppBar and bottom nav
      expect(find.text('Analytics'), findsAtLeastNWidgets(1));
    });
  });
}

/// Helper to create a test subscription
Subscription _createSubscription(
  String id, {
  double cost = 10.0,
  SubscriptionCategory category = SubscriptionCategory.entertainment,
}) {
  return Subscription(
    id: id,
    name: 'Test Sub $id',
    logoUrl: 'https://example.com/logo.png',
    semanticLabel: 'Test logo',
    cost: cost,
    billingCycle: BillingCycle.monthly,
    nextBillingDate: DateTime.now().add(const Duration(days: 10)),
    category: category,
    status: SubscriptionStatus.active,
    brandColor: const Color(0xFF1B365D),
  );
}

/// Helper to create a test trial
Trial _createTrial(int id, int daysFromNow) {
  return Trial(
    id: id,
    serviceName: 'Test Trial $id',
    logoUrl: 'https://example.com/logo.png',
    semanticLabel: 'Test logo',
    category: SubscriptionCategory.entertainment,
    trialEndDate: DateTime.now().add(Duration(days: daysFromNow)),
    conversionCost: 9.99,
    cancellationDifficulty: CancellationDifficulty.easy,
    cancellationUrl: 'https://example.com/cancel',
  );
}
