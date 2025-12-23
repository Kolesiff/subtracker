import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:subtracker/data/models/user_settings.dart';
import 'package:subtracker/data/repositories/settings_repository.dart';
import 'package:subtracker/presentation/account_settings/viewmodel/account_settings_viewmodel.dart';
import 'package:subtracker/presentation/account_settings/widgets/notification_toggle_widget.dart';
import 'package:subtracker/theme/app_theme.dart';

/// A minimal mock repository for widget testing that doesn't emit streams
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

void main() {
  group('NotificationToggleWidget', () {
    testWidgets('displays notification toggle switch', (tester) async {
      final repository = SimpleTestSettingsRepository();
      final viewModel = AccountSettingsViewModel(repository: repository);
      await viewModel.loadSettings();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AccountSettingsViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: NotificationToggleWidget()),
          ),
        ),
      );

      expect(find.byType(Switch), findsOneWidget);

      viewModel.dispose();
    });

    testWidgets('shows correct title', (tester) async {
      final repository = SimpleTestSettingsRepository();
      final viewModel = AccountSettingsViewModel(repository: repository);
      await viewModel.loadSettings();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AccountSettingsViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: NotificationToggleWidget()),
          ),
        ),
      );

      expect(find.text('Push Notifications'), findsOneWidget);

      viewModel.dispose();
    });

    testWidgets('shows subtitle text', (tester) async {
      final repository = SimpleTestSettingsRepository();
      final viewModel = AccountSettingsViewModel(repository: repository);
      await viewModel.loadSettings();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AccountSettingsViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: NotificationToggleWidget()),
          ),
        ),
      );

      expect(find.text('Enable all push notifications'), findsOneWidget);

      viewModel.dispose();
    });

    testWidgets('displays notification icon', (tester) async {
      final repository = SimpleTestSettingsRepository();
      final viewModel = AccountSettingsViewModel(repository: repository);
      await viewModel.loadSettings();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AccountSettingsViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: NotificationToggleWidget()),
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications_active_outlined), findsOneWidget);

      viewModel.dispose();
    });

    testWidgets('switch reflects enabled state', (tester) async {
      final repository = SimpleTestSettingsRepository();
      final viewModel = AccountSettingsViewModel(repository: repository);
      await viewModel.loadSettings();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AccountSettingsViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: NotificationToggleWidget()),
          ),
        ),
      );

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);

      viewModel.dispose();
    });

    testWidgets('switch reflects disabled state', (tester) async {
      final settings = UserSettings(
        id: 'id',
        userId: 'test-user',
        themeMode: ThemeMode.system,
        notificationsEnabled: false,
        currency: 'USD',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final repository = SimpleTestSettingsRepository(initialSettings: settings);
      final viewModel = AccountSettingsViewModel(repository: repository);
      await viewModel.loadSettings();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AccountSettingsViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: NotificationToggleWidget()),
          ),
        ),
      );

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);

      viewModel.dispose();
    });

    testWidgets('tapping switch updates viewModel', (tester) async {
      final repository = SimpleTestSettingsRepository();
      final viewModel = AccountSettingsViewModel(repository: repository);
      await viewModel.loadSettings();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AccountSettingsViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: NotificationToggleWidget()),
          ),
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(viewModel.isNotificationsEnabled, isFalse);

      viewModel.dispose();
    });

    testWidgets('switch has onChanged callback', (tester) async {
      final repository = SimpleTestSettingsRepository();
      final viewModel = AccountSettingsViewModel(repository: repository);
      await viewModel.loadSettings();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider<AccountSettingsViewModel>.value(
            value: viewModel,
            child: const Scaffold(body: NotificationToggleWidget()),
          ),
        ),
      );

      final switchWidget =
          tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(switchWidget.onChanged, isNotNull);

      viewModel.dispose();
    });
  });
}
