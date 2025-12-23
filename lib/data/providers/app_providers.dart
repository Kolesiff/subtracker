import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repositories/repositories.dart';
import '../../presentation/subscription_dashboard/viewmodel/dashboard_viewmodel.dart';
import '../../presentation/analytics/viewmodel/analytics_viewmodel.dart';
import '../../presentation/auth/viewmodel/auth_viewmodel.dart';
import '../../presentation/account_settings/viewmodel/account_settings_viewmodel.dart';

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

        // Repositories (singleton instances)
        Provider<SubscriptionRepository>(
          create: (_) => MockSubscriptionRepository(),
        ),
        Provider<TrialRepository>(
          create: (_) => MockTrialRepository(),
        ),
        Provider<SettingsRepository>(
          create: (_) => SupabaseSettingsRepository(),
        ),

        // Account Settings ViewModel
        ChangeNotifierProxyProvider<SettingsRepository, AccountSettingsViewModel>(
          create: (context) => AccountSettingsViewModel(
            repository: context.read<SettingsRepository>(),
          )..loadSettings(),
          update: (context, repository, previous) =>
              previous ?? AccountSettingsViewModel(repository: repository),
        ),

        // ViewModels (with automatic initialization)
        ChangeNotifierProxyProvider<SubscriptionRepository, DashboardViewModel>(
          create: (context) => DashboardViewModel(
            repository: context.read<SubscriptionRepository>(),
          )..loadSubscriptions(),
          update: (context, repository, previous) =>
              previous ?? DashboardViewModel(repository: repository),
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

  /// Get the dashboard viewmodel
  DashboardViewModel get dashboardViewModel => read<DashboardViewModel>();

  /// Watch the dashboard viewmodel for changes
  DashboardViewModel watchDashboardViewModel() => watch<DashboardViewModel>();

  /// Get the settings repository
  SettingsRepository get settingsRepository => read<SettingsRepository>();

  /// Get the account settings viewmodel
  AccountSettingsViewModel get settingsViewModel =>
      read<AccountSettingsViewModel>();

  /// Watch the account settings viewmodel for changes
  AccountSettingsViewModel watchSettingsViewModel() =>
      watch<AccountSettingsViewModel>();
}
