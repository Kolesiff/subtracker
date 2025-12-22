import 'package:flutter/material.dart';
import '../presentation/subscription_dashboard/subscription_dashboard.dart';
import '../presentation/trial_tracker/trial_tracker.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/subscription_detail/subscription_detail.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/add_subscription/add_subscription.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/analytics/analytics_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String subscriptionDashboard = '/subscription-dashboard';
  static const String trialTracker = '/trial-tracker';
  static const String splash = '/splash-screen';
  static const String subscriptionDetail = '/subscription-detail';
  static const String onboardingFlow = '/onboarding-flow';
  static const String addSubscription = '/add-subscription';
  static const String loginScreen = '/login-screen';
  static const String analytics = '/analytics';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    subscriptionDashboard: (context) => const SubscriptionDashboard(),
    trialTracker: (context) => const TrialTracker(),
    splash: (context) => const SplashScreen(),
    subscriptionDetail: (context) => const SubscriptionDetail(),
    onboardingFlow: (context) => const OnboardingFlow(),
    addSubscription: (context) => const AddSubscription(),
    loginScreen: (context) => const LoginScreen(),
    analytics: (context) => const AnalyticsScreen(),
  };
}
