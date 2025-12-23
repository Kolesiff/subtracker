# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run app in development
flutter build apk --release   # Build Android release
flutter build ios --release   # Build iOS release
flutter analyze          # Run linting/static analysis
flutter test             # Run unit tests
```

## Architecture

**MVVM with Provider pattern:**

```
lib/
├── core/                 # App-wide utilities and exports
├── data/
│   ├── models/           # Typed data models (Subscription, Trial, BillingHistory)
│   ├── repositories/     # Data layer interfaces and implementations
│   └── providers/        # Provider setup and dependency injection
├── presentation/         # Feature screens with ViewModels
│   └── <feature>/
│       ├── viewmodel/    # ChangeNotifier ViewModels
│       └── widgets/      # Feature-specific widgets
├── routes/               # Centralized navigation
├── theme/                # Material 3 theming
└── widgets/              # Shared reusable components
```

**Key Files:**
- `lib/data/models/subscription.dart` - Subscription model with BillingCycle, SubscriptionStatus, SubscriptionCategory enums
- `lib/data/models/trial.dart` - Trial model with UrgencyLevel, CancellationDifficulty enums
- `lib/data/models/app_user.dart` - User model with AuthProvider enum (email, google, apple)
- `lib/data/models/auth_result.dart` - Auth result wrapper with AuthError enum
- `lib/data/models/user_settings.dart` - User settings model (theme, notifications, currency)
- `lib/data/repositories/subscription_repository.dart` - Abstract repository interfaces
- `lib/data/repositories/mock_subscription_repository.dart` - Mock implementations for development
- `lib/data/repositories/auth_repository.dart` - Abstract auth interface
- `lib/data/repositories/supabase_auth_repository.dart` - Supabase auth implementation
- `lib/data/repositories/settings_repository.dart` - Abstract settings interface
- `lib/data/repositories/supabase_settings_repository.dart` - Supabase settings implementation
- `lib/data/providers/app_providers.dart` - MultiProvider setup wrapping the app
- `lib/presentation/subscription_dashboard/viewmodel/dashboard_viewmodel.dart` - Dashboard state management
- `lib/presentation/analytics/viewmodel/analytics_viewmodel.dart` - Analytics state management
- `lib/presentation/auth/viewmodel/auth_viewmodel.dart` - Authentication state management
- `lib/presentation/analytics/analytics_screen.dart` - Analytics dashboard (MVP with cards)
- `lib/presentation/account_settings/account_settings_screen.dart` - Account settings screen
- `lib/presentation/account_settings/viewmodel/account_settings_viewmodel.dart` - Settings state management

**State Management:**
```dart
// Access ViewModel in widgets
Consumer<DashboardViewModel>(
  builder: (context, viewModel, child) {
    return Text(viewModel.formattedTotalMonthlySpending);
  },
)

// Read without listening
context.read<DashboardViewModel>().loadSubscriptions();

// Watch for changes
context.watch<DashboardViewModel>().subscriptions;
```

**Design System ("Financial Clarity" theme):**
- Primary: #1B365D (light), #4A90A4 (dark)
- Accent: #FF6B35 (alerts)
- Success: #2ECC71, Warning: #F39C12, Error: #E74C3C
- Uses Google Fonts Inter for typography
- Border radii: 8px (small), 12px (medium), 16px (large)
- Spacing constants in `AppTheme`: spacingXSmall (4), spacingSmall (8), spacingMedium (16), spacingLarge (24), spacingXLarge (32)

## Critical Constraints

These sections in the code are marked with "CRITICAL: DO NOT REMOVE" - respect these:

1. **Device orientation lock** (`lib/main.dart`): Portrait-only mode
2. **TextScaler fix** (`lib/main.dart`): Fixed at 1.0 for consistent sizing
3. **Custom error widget** (`lib/main.dart`): Prevents error widget spam with 5-second cooldown
4. **AppProviders wrapper** (`lib/main.dart`): Must wrap the app for dependency injection

## Asset and Font Rules

- **Assets**: Only use `assets/` and `assets/images/` directories - do not create new asset folders
- **Fonts**: Use Google Fonts package only - no local font files allowed
- SVG icons via `flutter_svg`, images via `cached_network_image`

## Key Patterns

**Adding a new feature with MVVM:**
1. Create screen in `lib/presentation/<feature_name>/`
2. Create ViewModel in `lib/presentation/<feature_name>/viewmodel/`
3. Register ViewModel in `lib/data/providers/app_providers.dart`
4. Add route in `lib/routes/app_routes.dart`

**Working with models:**
```dart
// Models have computed properties
subscription.monthlyCost      // Calculated based on billingCycle
subscription.isExpiringSoon   // true if within 7 days
subscription.formattedCost    // "$15.99"

trial.urgencyLevel           // UrgencyLevel.critical/warning/safe
trial.timeRemainingText      // "5 days left"
```

**Responsive sizing with Sizer:**
```dart
Container(
  width: 50.w,   // 50% of screen width
  height: 20.h,  // 20% of screen height
)
```

**WARNING:** `.h` and `.w` are PERCENTAGES, not pixels!
- `24.h` = 24% of screen height (~195px on iPhone), NOT 24 pixels
- For fixed pixel spacing, use literal values: `SizedBox(height: 24)` or `AppTheme.spacingLarge`

**Theme access:**
```dart
Theme.of(context).colorScheme.primary
AppTheme.spacingMedium  // Static spacing constants
```

## Testing

Tests are in `test/` directory mirroring `lib/` structure:
- `test/data/models/` - Model unit tests (35 tests)
- `test/data/repositories/` - Repository tests (26 + 37 auth = 63 tests)
- `test/presentation/` - Widget tests for screens and ViewModels (49 + 28 auth + 28 login + 73 settings = 178 tests)
- `test/widgets/` - Widget tests for components (30 tests)
- `test/helpers/` - Shared test utilities
- `integration_test/` - Integration tests for user flows (4 tests)

**Total: ~310 tests** (auth: 97, account settings: 73)

Run specific test file:
```bash
flutter test test/data/models/subscription_test.dart
```

Run integration tests (requires device/emulator):
```bash
flutter test integration_test/
```

## Known Accessibility Limitation

**TextScaler fixed at 1.0:** The app disables system text scaling in `lib/main.dart` to ensure consistent UI sizing across devices. This is a deliberate design decision marked as "CRITICAL: DO NOT REMOVE" but limits accessibility for users who rely on larger system text. If accessibility compliance is required, this constraint should be revisited with careful UI testing.

## Theme Utilities

**UrgencyColors** (`lib/theme/urgency_colors.dart`): Theme-aware urgency color utility that returns appropriate colors (critical/warning/safe) based on current theme brightness. Use instead of hardcoding hex colors:

```dart
UrgencyColors.critical(context)  // Error color for critical urgency
UrgencyColors.warning(context)   // Warning color for warning urgency
UrgencyColors.safe(context)      // Success color for safe urgency
```

## Authentication (Supabase)

**Status:** 100% complete. Google OAuth fully working on Android.

**Configuration:**
- Supabase URL in `.env` file (gitignored)
- Initialize in `main.dart` with `flutter_dotenv`

**Auth Flow:**
```
SplashScreen → checks SharedPreferences('onboarding_complete') + AuthViewModel.isAuthenticated
    ├─ Not onboarded → OnboardingFlow → LoginScreen
    ├─ Not authenticated → LoginScreen (Sign In / Sign Up tabs)
    └─ Authenticated → SubscriptionDashboard
```

**Using AuthViewModel:**
```dart
// Access auth state
Consumer<AuthViewModel>(
  builder: (context, viewModel, _) {
    if (viewModel.isAuthenticated) { ... }
    if (viewModel.isLoading) { ... }
    if (viewModel.errorMessage != null) { ... }
  },
)

// Auth actions
context.read<AuthViewModel>().signIn(email: email, password: password);
context.read<AuthViewModel>().signUp(email: email, password: password);
context.read<AuthViewModel>().signInWithGoogle();
context.read<AuthViewModel>().signOut();

// Form validation
viewModel.validateEmail(email);       // Returns null if valid, error string if invalid
viewModel.validatePassword(password); // Requires 8+ chars, uppercase, lowercase, number
```

**Completed Auth Tasks:**
1. ✅ Add Supabase anon key to `.env`
2. ✅ Configure Google OAuth deep links in AndroidManifest.xml
3. ✅ Enable Google provider in Supabase dashboard
4. ✅ Fix AuthViewModel stream subscription for OAuth callbacks
5. ✅ Add 97 auth tests (all passing)

**Google OAuth Config:**
- Package: `com.subtracker.app`
- SHA-1 (debug): `87:DF:AA:9E:1D:11:F3:38:62:C9:5C:A6:4F:6E:1E:69:B4:47:0F:28`
- Redirect URI: `https://pfvrusdcaepsagcxzwzi.supabase.co/auth/v1/callback`

## Account Settings

**Status:** 100% complete. Full UI with dynamic theme switching.

**Navigation:** Bottom nav bar has Account tab. FAB handles adding subscriptions.

**Features:**
- Profile header (displays user info from AuthViewModel)
- Theme selector (Light/Dark/System) - dynamically updates app theme
- Currency selector (10 currencies)
- Notifications toggle
- Logout with confirmation dialog

**Supabase Table:** Run this SQL in Supabase SQL Editor (required for persistence):
```sql
CREATE TABLE user_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  theme_mode TEXT DEFAULT 'system' CHECK (theme_mode IN ('system', 'light', 'dark')),
  notifications_enabled BOOLEAN DEFAULT true,
  currency TEXT DEFAULT 'USD',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own settings" ON user_settings
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own settings" ON user_settings
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own settings" ON user_settings
  FOR UPDATE USING (auth.uid() = user_id);
```

**Using AccountSettingsViewModel:**
```dart
// Access settings state
Consumer<AccountSettingsViewModel>(
  builder: (context, viewModel, _) {
    if (viewModel.isLoading) { ... }
    if (viewModel.status == AccountSettingsStatus.error) { ... }
    final theme = viewModel.currentThemeMode;
    final currency = viewModel.currentCurrency;
    final notifications = viewModel.isNotificationsEnabled;
  },
)

// Update settings
context.read<AccountSettingsViewModel>().updateThemeMode(ThemeMode.dark);
context.read<AccountSettingsViewModel>().updateNotificationsEnabled(false);
context.read<AccountSettingsViewModel>().updateCurrency('EUR');
```

**Key Files:**
- `lib/presentation/account_settings/account_settings_screen.dart` - Main screen
- `lib/presentation/account_settings/viewmodel/account_settings_viewmodel.dart` - ViewModel
- `lib/presentation/account_settings/widgets/` - ProfileHeader, AppPreferences, NotificationToggle, AccountActions
- `test/presentation/account_settings/` - 73 tests (TDD)

---

## Remaining Backlog

1. **Sizer percentage usage** - Some files use `.h`/`.w` for spacing. These are intentional for responsive design but should be reviewed for consistency.
2. **Pre-existing lint warnings** - ~25 lint issues exist (unused variables, deprecated API usage). Run `flutter analyze` to see details.
3. **Golden tests** - Not implemented. Consider adding visual regression tests for key screens if needed.
4. **Auth integration tests** - Add integration tests for full auth flow.
5. **Supabase migration** - Run user_settings table SQL in Supabase dashboard for settings persistence.
