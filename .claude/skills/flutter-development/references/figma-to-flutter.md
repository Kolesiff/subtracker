# Figma to Flutter Workflow Guide

## Design Handoff Process

### 1. Figma Design Best Practices

#### Structure for Developers
- Use **Frames** for each screen (Home, Profile, Settings)
- Group related elements using **Components**
- Label layers clearly (e.g., `btn_primary_active`, `card_user`)
- Use **Auto Layout** for responsive behavior
- Create **Variants** for states (hover, pressed, disabled)

#### Design Tokens
- Define colors as **Color Styles**
- Create **Text Styles** for typography
- Use consistent **Spacing** values (4, 8, 16, 24, 32)
- Define **Effects** for shadows and blurs

### 2. Extracting Design Specs from Figma

#### Using Figma Dev Mode
1. Enable Dev Mode in Figma
2. Select element to see:
   - Dimensions (width, height)
   - Spacing (padding, margin)
   - Colors (hex, rgba)
   - Typography (font, size, weight, line-height)
   - Border radius
   - Shadows

#### Export Assets
1. Select icon/image
2. Export panel → Choose format:
   - **SVG** for icons (scalable)
   - **PNG** for images (@1x, @2x, @3x)
   - **PDF** for iOS assets
3. Download and add to `assets/` folder

---

## Figma to Flutter Tools

### 1. Visual Copilot (Builder.io)
- **Best for**: AI-powered conversion
- **URL**: https://www.builder.io/blog/figma-to-flutter
- **Features**:
  - Generates clean Flutter/Dart code
  - Handles responsive layouts
  - CLI integration for VS Code/Cursor

### 2. DhiWise
- **Best for**: Full project generation
- **URL**: https://dhiwise.com
- **Features**:
  - Import Figma designs
  - Generate complete Flutter screens
  - API integration support

### 3. FlutterFlow
- **Best for**: No-code/low-code development
- **URL**: https://flutterflow.io
- **Features**:
  - Visual Flutter builder
  - Direct Figma import
  - Export clean Flutter code

### 4. Parabeac
- **Best for**: Open-source conversion
- **URL**: https://parabeac.com
- **Features**:
  - Figma plugin
  - Auto-generates widgets
  - Customizable output

### 5. Figma Dev Mode + Manual
- **Best for**: Precise control
- **Process**: Extract specs manually, build widgets

---

## Manual Conversion Workflow

### Step 1: Analyze the Design
1. Identify repeating components → Create reusable widgets
2. Note color palette → Define in theme
3. Extract typography → Create text styles
4. List all assets needed → Export from Figma

### Step 2: Set Up Theme
```dart
// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Colors (from Figma Color Styles)
  static const Color primary = Color(0xFF6200EE);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB00020);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1C1B1F);

  // Typography (from Figma Text Styles)
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.25,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  // Spacing (from Figma spacing system)
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;

  // Border Radius
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 16;
  static const double radiusFull = 999;

  // Shadows
  static List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  // ThemeData
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      textTheme: const TextTheme(
        headlineLarge: headlineLarge,
        bodyLarge: bodyLarge,
      ),
    );
  }
}
```

### Step 3: Create Components
```dart
// lib/presentation/widgets/primary_button.dart
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48, // From Figma
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.onPrimary,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
```

### Step 4: Build Screens
```dart
// Translate Figma frame to Flutter
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppTheme.spacingXl),
              Text(
                'Welcome Back',
                style: AppTheme.headlineLarge,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                'Sign in to continue',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXl),
              // Form fields...
              const Spacer(),
              PrimaryButton(
                text: 'Sign In',
                onPressed: () {},
              ),
              const SizedBox(height: AppTheme.spacingMd),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Design Tokens with Tokens Studio

### Workflow
1. Install **Tokens Studio** plugin in Figma
2. Define tokens (colors, typography, spacing)
3. Export as JSON
4. Use **style_dictionary** or **Supernova** to generate Dart code

### Example Token Export
```json
{
  "colors": {
    "primary": { "value": "#6200EE" },
    "secondary": { "value": "#03DAC6" }
  },
  "spacing": {
    "sm": { "value": "8px" },
    "md": { "value": "16px" }
  }
}
```

---

## Responsive Design

### MediaQuery
```dart
final screenWidth = MediaQuery.of(context).size.width;
final isTablet = screenWidth >= 600;
final isDesktop = screenWidth >= 1024;
```

### LayoutBuilder
```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth >= 1024) {
      return DesktopLayout();
    } else if (constraints.maxWidth >= 600) {
      return TabletLayout();
    }
    return MobileLayout();
  },
)
```

### flutter_screenutil Package
```yaml
dependencies:
  flutter_screenutil: ^5.9.0
```

```dart
// Initialize in main
ScreenUtil.init(context, designSize: const Size(375, 812));

// Use adaptive sizing
Container(
  width: 100.w,  // 100 logical pixels on design, scales proportionally
  height: 50.h,
  padding: EdgeInsets.all(16.r),
  child: Text('Hello', style: TextStyle(fontSize: 14.sp)),
)
```

---

## Best Practices

1. **Component Library First**: Build reusable widgets before screens
2. **Match Figma Names**: Use similar naming for easy reference
3. **Design System**: Create a comprehensive theme file
4. **Atomic Design**: Build atoms → molecules → organisms → screens
5. **Version Control**: Keep design specs in sync with code
6. **Communicate**: Regular syncs between designers and developers
