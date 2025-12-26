import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repositories/repositories.dart';
import '../repositories/supabase_subscription_repository.dart';
import '../repositories/supabase_trial_repository.dart';
import '../../presentation/subscription_dashboard/viewmodel/dashboard_viewmodel.dart';
import '../../presentation/analytics/viewmodel/analytics_viewmodel.dart';
import '../../presentation/auth/viewmodel/auth_viewmodel.dart';
import '../../presentation/account_settings/viewmodel/account_settings_viewmodel.dart';
import '../../presentation/trial_tracker/viewmodel/trial_viewmodel.dart';

/// Creates the list of providers for the application
/// Wraps the app with all necessary dependency injection
class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Repository (Supabase implementation)
        Provider<AuthRepository>(
          create: (_) => SupabaseAuthRepository(),
        ),

        // Auth ViewModel
        ChangeNotifierProxyProvider<AuthRepository, AuthViewModel>(
          create: (context) => AuthViewModel(
            repository: context.read<AuthRepository>(),
          ),
          update: (context, repository, previous) =>
              previous ?? AuthViewModel(repository: repository),
        ),

        // Repositories (Supabase implementations for user-specific data)
        Provider<SubscriptionRepository>(
          create: (_) => SupabaseSubscriptionRepository(),
        ),
        Provider<TrialRepository>(
          create: (_) => SupabaseTrialRepository(),
        ),
        Provider<SettingsRepository>(
          create: (_) => SupabaseSettingsRepository(),
        ),
        Provider<BillingHistoryRepository>(
          create: (_) => SupabaseBillingHistoryRepository(),
        ),

        // Notification Repository
        Provider<NotificationRepository>(
          create: (_) => NotificationRepositoryImpl(),
        ),

        // Account Settings ViewModel
        ChangeNotifierProxyProvider<SettingsRepository, AccountSettingsViewModel>(
          create: (context) => AccountSettingsViewModel(
            repository: context.read<SettingsRepository>(),
          )..loadSettings(),
          update: (context, repository, previous) =>
              previous ?? AccountSettingsViewModel(repository: repository),
        ),

        // Dashboard ViewModel (with automatic initialization and notification support)
        ChangeNotifierProxyProvider2<SubscriptionRepository, NotificationRepository,
            DashboardViewModel>(
          create: (context) => DashboardViewModel(
            repository: context.read<SubscriptionRepository>(),
            notificationRepository: context.read<NotificationRepository>(),
          )..loadSubscriptions(),
          update: (context, repository, notificationRepo, previous) =>
              previous ??
              DashboardViewModel(
                repository: repository,
                notificationRepository: notificationRepo,
              ),
        ),

        // Trial ViewModel (with automatic initialization and notification support)
        ChangeNotifierProxyProvider2<TrialRepository, NotificationRepository,
            TrialViewModel>(
          create: (context) => TrialViewModel(
            repository: context.read<TrialRepository>(),
            notificationRepository: context.read<NotificationRepository>(),
          )..loadTrials(),
          update: (context, repository, notificationRepo, previous) =>
              previous ??
              TrialViewModel(
                repository: repository,
                notificationRepository: notificationRepo,
              ),
        ),

        // Analytics ViewModel
        ChangeNotifierProxyProvider2<SubscriptionRepository, TrialRepository,
            AnalyticsViewModel>(
          create: (context) => AnalyticsViewModel(
            subscriptionRepository: context.read<SubscriptionRepository>(),
            trialRepository: context.read<TrialRepository>(),
          ),
          update: (context, subRepo, trialRepo, previous) =>
              previous ??
              AnalyticsViewModel(
                subscriptionRepository: subRepo,
                trialRepository: trialRepo,
              ),
        ),
      ],
      child: child,
    );
  }
}

/// Extension for easy access to repositories and viewmodels
extension ContextProviderExtensions on BuildContext {
  /// Get the auth repository
  AuthRepository get authRepository => read<AuthRepository>();

  /// Get the auth viewmodel
  AuthViewModel get authViewModel => read<AuthViewModel>();

  /// Watch the auth viewmodel for changes
  AuthViewModel watchAuthViewModel() => watch<AuthViewModel>();

  /// Get the subscription repository
  SubscriptionRepository get subscriptionRepository =>
      read<SubscriptionRepository>();

  /// Get the trial repository
  TrialRepository get trialRepository => read<TrialRepository>();

  /// Get the trial viewmodel
  TrialViewModel get trialViewModel => read<TrialViewModel>();

  /// Watch the trial viewmodel for changes
  TrialViewModel watchTrialViewModel() => watch<TrialViewModel>();

  /// Get the dashboard viewmodel
  DashboardViewModel get dashboardViewModel => read<DashboardViewModel>();

  /// Watch the dashboard viewmodel for changes
  DashboardViewModel watchDashboardViewModel() => watch<DashboardViewModel>();

  /// Get the settings repository
  SettingsRepository get settingsRepository => read<SettingsRepository>();

  /// Get the billing history repository
  BillingHistoryRepository get billingHistoryRepository =>
      read<BillingHistoryRepository>();

  /// Get the notification repository
  NotificationRepository get notificationRepository =>
      read<NotificationRepository>();

  /// Get the account settings viewmodel
  AccountSettingsViewModel get settingsViewModel =>
      read<AccountSettingsViewModel>();

  /// Watch the account settings viewmodel for changes
  AccountSettingsViewModel watchSettingsViewModel() =>
      watch<AccountSettingsViewModel>();
}
