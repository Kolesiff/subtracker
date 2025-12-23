import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:subtracker/data/models/app_user.dart';
import 'package:subtracker/data/models/auth_result.dart';
import 'package:subtracker/data/models/user_settings.dart';
import 'package:subtracker/data/repositories/auth_repository.dart';
import 'package:subtracker/data/repositories/settings_repository.dart';
import 'package:subtracker/presentation/account_settings/account_settings_screen.dart';
import 'package:subtracker/presentation/account_settings/viewmodel/account_settings_viewmodel.dart';
import 'package:subtracker/presentation/auth/viewmodel/auth_viewmodel.dart';
import 'package:subtracker/theme/app_theme.dart';
import 'package:subtracker/widgets/custom_bottom_bar.dart';

/// Mock settings repository for testing
class SimpleTestSettingsRepository implements SettingsRepository {
  UserSettings? _settings;

  SimpleTestSettingsRepository({UserSettings? initialSettings})
      : _settings = initialSettings;

  @override
  Future<UserSettings?> getSettings() async {
    _settings ??= UserSettings.defaults('test-user');
    return _settings;
  }

  @override
  Future<UserSettings> saveSettings(UserSettings settings) async {
    _settings = settings;
    return _settings!;
  }

  @override
  Future<UserSettings> updateThemeMode(ThemeMode mode) async {
    _settings = _settings!.copyWith(themeMode: mode);
    return _settings!;
  }

  @override
  Future<UserSettings> updateNotificationsEnabled(bool enabled) async {
    _settings = _settings!.copyWith(notificationsEnabled: enabled);
    return _settings!;
  }

  @override
  Future<UserSettings> updateCurrency(String currency) async {
    _settings = _settings!.copyWith(currency: currency);
    return _settings!;
  }

  @override
  Future<void> deleteSettings() async {
    _settings = null;
  }

  @override
  Stream<UserSettings?> get settingsStream => const Stream.empty();
}

/// Mock auth repository for testing
class SimpleTestAuthRepository implements AuthRepository {
  AppUser? _currentUser;

  SimpleTestAuthRepository({AppUser? currentUser}) : _currentUser = currentUser;

  @override
  AppUser? getCurrentUser() => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;

  @override
  Stream<AppUser?> get authStateChanges => const Stream.empty();

  @override
  Future<AuthResult> signIn({required String email, required String password}) async {
    throw UnimplementedError();
  }

  @override
  Future<AuthResult> signUp({required String email, required String password}) async {
    throw UnimplementedError();
  }

  @override
  Future<AuthResult> signInWithGoogle() async {
    throw UnimplementedError();
  }

  @override
  Future<AuthResult> signInWithApple() async {
    throw UnimplementedError();
  }

  @override
  Future<AuthResult> signOut() async {
    _currentUser = null;
    return AuthResult.success(AppUser(id: '', email: '', createdAt: DateTime.now()));
  }

  @override
  Future<AuthResult> resetPassword({required String email}) async {
    throw UnimplementedError();
  }
}

void main() {
  group('AccountSettingsScreen', () {
    late SimpleTestSettingsRepository settingsRepository;
    late AccountSettingsViewModel settingsViewModel;
    late SimpleTestAuthRepository authRepository;
    late AuthViewModel authViewModel;

    setUp(() async {
      final user = AppUser(
        id: 'test-id',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: DateTime.now(),
      );
      authRepository = SimpleTestAuthRepository(currentUser: user);
      authViewModel = AuthViewModel(repository: authRepository);

      settingsRepository = SimpleTestSettingsRepository();
      settingsViewModel = AccountSettingsViewModel(repository: settingsRepository);
      await settingsViewModel.loadSettings();
    });

    tearDown(() {
      settingsViewModel.dispose();
      authViewModel.dispose();
    });

    Widget createTestWidget() {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AccountSettingsViewModel>.value(
              value: settingsViewModel,
            ),
            ChangeNotifierProvider<AuthViewModel>.value(
              value: authViewModel,
            ),
          ],
          child: const AccountSettingsScreen(),
        ),
        routes: {
          '/subscription-dashboard': (_) =>
              const Scaffold(body: Text('Dashboard')),
          '/trial-tracker': (_) => const Scaffold(body: Text('Trials')),
          '/analytics': (_) => const Scaffold(body: Text('Analytics')),
          '/login-screen': (_) => const Scaffold(body: Text('Login')),
        },
      );
    }

    testWidgets('displays app bar with Account Settings title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Account Settings'), findsOneWidget);
    });

    testWidgets('displays bottom navigation bar', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CustomBottomBar), findsOneWidget);
    });

    testWidgets('renders ProfileHeaderWidget', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Profile header shows user info
      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('renders NotificationToggleWidget', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Push Notifications'), findsOneWidget);
    });

    testWidgets('renders AppPreferencesWidget', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('App Preferences'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
    });

    testWidgets('renders AccountActionsWidget', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Account section title and Logout button exist
      expect(find.text('Account'), findsWidgets); // Section + bottom nav
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('is scrollable', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('account tab is selected in bottom nav', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final bottomBar = tester.widget<CustomBottomBar>(
        find.byType(CustomBottomBar),
      );
      expect(bottomBar.currentItem, CustomBottomBarItem.account);
    });
  });
}
