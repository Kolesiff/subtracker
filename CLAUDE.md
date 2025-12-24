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
- `lib/data/models/subscription.dart` - Subscription model with BillingCycle, SubscriptionStatus, SubscriptionCategory enums + `fromJson()`/`toJson()` for Supabase
- `lib/data/models/trial.dart` - Trial model (id is String/UUID) with UrgencyLevel, CancellationDifficulty enums + `fromJson()`/`toJson()` for Supabase
- `lib/data/models/app_user.dart` - User model with AuthProvider enum (email, google, apple)
- `lib/data/models/auth_result.dart` - Auth result wrapper with AuthError enum
- `lib/data/models/user_settings.dart` - User settings model (theme, notifications, currency)
- `lib/data/repositories/subscription_repository.dart` - Abstract repository interfaces (includes `subscriptionsStream` and `trialsStream`)
- `lib/data/repositories/supabase_subscription_repository.dart` - **Supabase implementation for user subscriptions**
- `lib/data/repositories/supabase_trial_repository.dart` - **Supabase implementation for user trials**
- `lib/data/repositories/mock_subscription_repository.dart` - Mock implementations for development/testing
- `lib/data/repositories/auth_repository.dart` - Abstract auth interface
- `lib/data/repositories/supabase_auth_repository.dart` - Supabase auth implementation
- `lib/data/repositories/settings_repository.dart` - Abstract settings interface
- `lib/data/repositories/supabase_settings_repository.dart` - Supabase settings implementation
- `lib/data/providers/app_providers.dart` - MultiProvider setup (uses Supabase repos by default)
- `lib/presentation/subscription_dashboard/viewmodel/dashboard_viewmodel.dart` - Dashboard state management with real-time stream
- `lib/presentation/analytics/viewmodel/analytics_viewmodel.dart` - Analytics state management (real-time streams)
- `lib/presentation/trial_tracker/viewmodel/trial_viewmodel.dart` - **Trial state management with real-time streams**
- `lib/presentation/add_trial/add_trial.dart` - **Add Trial form screen**
- `lib/presentation/auth/viewmodel/auth_viewmodel.dart` - Authentication state management
- `lib/core/constants/category_colors.dart` - **Auto-assigns brandColor by SubscriptionCategory**
- `lib/data/repositories/supabase_billing_history_repository.dart` - **Billing history repository (needs table)**
- `lib/presentation/analytics/analytics_screen.dart` - Analytics dashboard (MVP with cards)
- `lib/presentation/account_settings/account_settings_screen.dart` - Account settings screen
- `lib/presentation/account_settings/viewmodel/account_settings_viewmodel.dart` - Settings state management
- `lib/presentation/subscription_detail/subscription_detail.dart` - Subscription detail with working cancel/delete

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

**Total: ~272 passing tests** (6 pre-existing failures unrelated to app logic)

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

## Subscriptions & Trials (Supabase)

**Status:** 100% complete. User-specific data with real-time sync.

**Architecture:**
- `SupabaseSubscriptionRepository` and `SupabaseTrialRepository` store data per user
- Real-time streams update UI automatically when data changes
- Cancel/delete buttons in SubscriptionDetail now work correctly

**Supabase Tables:** Already created in Supabase dashboard:
- `subscriptions` - User subscriptions with RLS policies
- `trials` - User trials with RLS policies

**Key Implementation Details:**
- `Trial.id` is `String` (UUID), not int
- Models have both `toMap()`/`fromMap()` (camelCase) and `toJson()`/`fromJson()` (snake_case for Supabase)
- **IMPORTANT:** `toJson()` excludes `semantic_label` field (not in Supabase tables)
- **IMPORTANT:** `brand_color` stored as hex string (e.g., `"#FF1B365D"`) not integer (avoids PostgreSQL overflow)
- `_parseColor()` helper in subscription.dart handles both int and hex string formats from DB
- `DashboardViewModel.filteredSubscriptions` excludes cancelled subscriptions
- `DashboardViewModel.totalMonthlySpending` excludes cancelled subscriptions
- `DashboardViewModel` subscribes to real-time stream in constructor
- `SubscriptionDetail` accepts `subscriptionId` parameter and loads from ViewModel
- Navigation uses `onGenerateRoute` for routes requiring arguments

**Using DashboardViewModel:**
```dart
// Get subscription by ID
final sub = context.read<DashboardViewModel>().getSubscriptionById(id);

// CRUD operations (auto-synced via real-time stream)
await viewModel.addSubscription(subscription);
await viewModel.updateSubscription(subscription);
await viewModel.deleteSubscription(id);

// Cancel = update status to cancelled
final cancelled = subscription.copyWith(status: SubscriptionStatus.cancelled);
await viewModel.updateSubscription(cancelled);
```

**Navigating to SubscriptionDetail:**
```dart
Navigator.pushNamed(
  context,
  '/subscription-detail',
  arguments: {'subscriptionId': subscription.id},
);
```

---

## Add Subscription (Supabase Connected)

**Status:** 100% complete. Form persists to Supabase.

**Input Methods:** Manual and Popular (Scan feature removed)

**Popular Services:** 45 pre-configured services with Google Play Store icons:
- Entertainment: Netflix, Spotify, Disney+, Max, YouTube, Apple Music, Amazon Prime, Hulu, Peacock, Paramount+, Crunchyroll, Twitch, Discord Nitro, PlayStation, Xbox Game Pass
- Productivity: Microsoft 365, Notion, Slack, Zoom, Canva, Evernote, Google One, Dropbox, OneDrive, 1Password, NordVPN, ExpressVPN
- Health: Headspace, Calm, Strava, MyFitnessPal, Fitbit Premium
- Education: Duolingo Plus, LinkedIn Premium, Coursera, Skillshare
- Shopping: DoorDash, Uber Eats, Instacart
- News: Audible, Kindle, Medium

**Key Files:**
- `lib/presentation/add_subscription/add_subscription.dart` - Form with save to Supabase
- `lib/core/constants/category_colors.dart` - Auto-assigns brandColor by category

**How it works:**
- Selecting a popular service captures `_selectedLogoUrl` along with name, cost, category
- `_saveSubscription()` builds `Subscription` with UUID, logoUrl, and auto-assigned brandColor
- Calls `DashboardViewModel.addSubscription()` to persist
- Shows loading indicator during save, error snackbar on failure
- Real-time stream auto-updates dashboard after save

---

## Trial Tracker (Supabase Connected)

**Status:** 100% complete. Fully integrated with TrialViewModel and real-time streams.

**Key Files:**
- `lib/presentation/trial_tracker/viewmodel/trial_viewmodel.dart` - ViewModel with streams
- `lib/presentation/add_trial/add_trial.dart` - Add Trial form screen
- `lib/presentation/trial_tracker/trial_tracker.dart` - Main screen using `Consumer<TrialViewModel>`

**How it works:**
- Uses `Consumer<TrialViewModel>` to display real user trials (no mock data)
- `_trialToMap()` converts Trial models to Maps for widget compatibility
- Filter chips use `viewModel.setCategory()` and `viewModel.setTimeframe()`
- Cancel actions call `viewModel.cancelTrial(id)` - UI updates via real-time stream

**Using TrialViewModel:**
```dart
Consumer<TrialViewModel>(
  builder: (context, viewModel, _) {
    if (viewModel.isLoading) { ... }
    final trials = viewModel.filteredTrials;
    final critical = viewModel.criticalCount;
  },
)

// CRUD operations
await context.read<TrialViewModel>().addTrial(trial);
await context.read<TrialViewModel>().cancelTrial(id);
await context.read<TrialViewModel>().deleteTrial(id);
```

---

## Analytics (Real-time Streams)

**Status:** 100% complete. AnalyticsViewModel now uses real-time streams.

**Key Changes:**
- Subscribes to `subscriptionsStream` and `trialsStream` in constructor
- Auto-updates when data changes (no manual refresh needed)
- Proper `dispose()` cancels stream subscriptions

---

## Billing History (Repository Ready)

**Status:** Repository complete. Needs Supabase table created.

**Key Files:**
- `lib/data/models/billing_history.dart` - Model with `fromJson()`/`toJson()`
- `lib/data/repositories/supabase_billing_history_repository.dart` - CRUD + streams
- `lib/data/repositories/subscription_repository.dart` - `BillingHistoryRepository` interface

**Supabase SQL (run in SQL Editor):**
```sql
CREATE TABLE billing_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subscription_id UUID NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  billing_date TIMESTAMPTZ NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  status TEXT DEFAULT 'completed' CHECK (status IN ('completed', 'pending', 'failed', 'refunded')),
  payment_method TEXT,
  transaction_id TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_billing_history_subscription_id ON billing_history(subscription_id);
CREATE INDEX idx_billing_history_user_id ON billing_history(user_id);

ALTER TABLE billing_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own billing history" ON billing_history
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own billing history" ON billing_history
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own billing history" ON billing_history
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own billing history" ON billing_history
  FOR DELETE USING (auth.uid() = user_id);
```

---

## Remaining Backlog

1. **Sizer percentage usage** - Some files use `.h`/`.w` for spacing. Intentional for responsive design.
2. **Pre-existing lint warnings** - ~25 lint issues exist. Run `flutter analyze` to see details.
3. **Pre-existing test failures** - 7 tests fail (CustomBottomBar/CustomAppBar related). Not related to app logic.
4. **HistoryTabWidget** - Needs to call `BillingHistoryRepository` to display real billing records.
5. **Supabase `brand_color` column** - Must be TEXT type (not INTEGER) to store hex color strings.
