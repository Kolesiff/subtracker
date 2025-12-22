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
- `lib/data/repositories/subscription_repository.dart` - Abstract repository interfaces
- `lib/data/repositories/mock_subscription_repository.dart` - Mock implementations for development
- `lib/data/providers/app_providers.dart` - MultiProvider setup wrapping the app
- `lib/presentation/subscription_dashboard/viewmodel/dashboard_viewmodel.dart` - Dashboard state management
- `lib/presentation/analytics/viewmodel/analytics_viewmodel.dart` - Analytics state management
- `lib/presentation/analytics/analytics_screen.dart` - Analytics dashboard (MVP with cards)

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
- `test/data/repositories/` - Repository tests (26 tests)
- `test/presentation/` - Widget tests for screens and ViewModels (49 tests)
- `test/widgets/` - Widget tests for components (30 tests)
- `test/helpers/` - Shared test utilities
- `integration_test/` - Integration tests for user flows (4 tests)

**Total: 139 tests** (all passing)

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

## Remaining Backlog

1. **Sizer percentage usage** - Some files use `.h`/`.w` for spacing. These are intentional for responsive design but should be reviewed for consistency.
2. **Pre-existing lint warnings** - 24 lint issues exist (unused variables, deprecated API usage). Run `flutter analyze` to see details.
3. **Golden tests** - Not implemented. Consider adding visual regression tests for key screens if needed.
