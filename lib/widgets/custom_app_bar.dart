import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App bar style variants for different screen contexts
enum CustomAppBarStyle {
  /// Standard app bar with title and actions
  standard,

  /// Large app bar with prominent title for main screens
  large,

  /// Transparent app bar for overlay contexts
  transparent,

  /// Search-focused app bar with search field
  search,
}

/// Custom app bar widget implementing Financial Clarity design system
/// Provides clean, professional navigation with contextual actions
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// App bar title text
  final String? title;

  /// Leading widget (typically back button or menu)
  final Widget? leading;

  /// Action widgets displayed on the right side
  final List<Widget>? actions;

  /// App bar style variant
  final CustomAppBarStyle style;

  /// Whether to show back button automatically
  final bool automaticallyImplyLeading;

  /// Custom elevation (default: 0 for clean look)
  final double elevation;

  /// Whether to center the title
  final bool centerTitle;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom foreground color for text and icons
  final Color? foregroundColor;

  /// Bottom widget (typically TabBar)
  final PreferredSizeWidget? bottom;

  /// Callback when back button is pressed
  final VoidCallback? onBackPressed;

  /// Search query callback for search style
  final ValueChanged<String>? onSearchChanged;

  /// Search hint text
  final String searchHint;

  /// Whether to enable haptic feedback
  final bool enableHapticFeedback;

  const CustomAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.style = CustomAppBarStyle.standard,
    this.automaticallyImplyLeading = true,
    this.elevation = 0.0,
    this.centerTitle = false,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
    this.onBackPressed,
    this.onSearchChanged,
    this.searchHint = 'Search subscriptions...',
    this.enableHapticFeedback = true,
  });

  @override
  Size get preferredSize {
    double height = 56.0; // Standard app bar height

    if (style == CustomAppBarStyle.large) {
      height = 112.0; // Large app bar height
    }

    if (bottom != null) {
      height += bottom!.preferredSize.height;
    }

    return Size.fromHeight(height);
  }

  /// Build leading widget with back button handling
  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (automaticallyImplyLeading) {
      final canPop = Navigator.canPop(context);
      if (canPop) {
        return IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (enableHapticFeedback) {
              HapticFeedback.lightImpact();
            }
            if (onBackPressed != null) {
              onBackPressed!();
            } else {
              Navigator.pop(context);
            }
          },
          tooltip: 'Back',
        );
      }
    }

    return null;
  }

  /// Build title widget based on style
  Widget? _buildTitle(BuildContext context) {
    if (title == null) return null;

    final theme = Theme.of(context);

    switch (style) {
      case CustomAppBarStyle.large:
        return Text(
          title!,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: foregroundColor ?? theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.w600,
          ),
        );

      case CustomAppBarStyle.search:
        return null; // Search field replaces title

      case CustomAppBarStyle.standard:
      case CustomAppBarStyle.transparent:
      default:
        return Text(
          title!,
          style: theme.appBarTheme.titleTextStyle?.copyWith(
            color: foregroundColor ?? theme.appBarTheme.foregroundColor,
          ),
        );
    }
  }

  /// Build search field for search style
  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.16),
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: onSearchChanged,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: searchHint,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.clear_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
            onPressed: () {
              if (onSearchChanged != null) {
                onSearchChanged!('');
              }
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  /// Build actions with proper spacing
  List<Widget>? _buildActions(BuildContext context) {
    if (actions == null || actions!.isEmpty) return null;

    return [
      ...actions!,
      const SizedBox(width: 8), // Trailing spacing
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine background color based on style
    Color effectiveBackgroundColor =
        backgroundColor ??
        (style == CustomAppBarStyle.transparent
            ? Colors.transparent
            : theme.appBarTheme.backgroundColor ?? colorScheme.surface);

    // Determine system overlay style
    final brightness = ThemeData.estimateBrightnessForColor(
      effectiveBackgroundColor,
    );
    final overlayStyle = brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    if (style == CustomAppBarStyle.large) {
      // Use regular AppBar with toolbarHeight for large style
      // SliverAppBar cannot be used in Scaffold.appBar context
      return AppBar(
        toolbarHeight:
            preferredSize.height - (bottom?.preferredSize.height ?? 0),
        elevation: elevation,
        backgroundColor: effectiveBackgroundColor,
        foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
        systemOverlayStyle: overlayStyle,
        leading: _buildLeading(context),
        automaticallyImplyLeading: false,
        centerTitle: centerTitle,
        title: _buildTitle(context),
        actions: _buildActions(context),
        bottom: bottom,
      );
    }

    if (style == CustomAppBarStyle.search) {
      return AppBar(
        elevation: elevation,
        backgroundColor: effectiveBackgroundColor,
        foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
        systemOverlayStyle: overlayStyle,
        leading: _buildLeading(context),
        automaticallyImplyLeading: false,
        title: _buildSearchField(context),
        actions: _buildActions(context),
        bottom: bottom,
      );
    }

    return AppBar(
      elevation: elevation,
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      systemOverlayStyle: overlayStyle,
      leading: _buildLeading(context),
      automaticallyImplyLeading: false,
      title: _buildTitle(context),
      centerTitle: centerTitle,
      actions: _buildActions(context),
      bottom: bottom,
    );
  }
}

/// Pre-configured app bar variants for common use cases
class CustomAppBarVariants {
  CustomAppBarVariants._();

  /// Dashboard app bar with menu and notifications
  static CustomAppBar dashboard({
    required BuildContext context,
    VoidCallback? onMenuPressed,
    VoidCallback? onNotificationPressed,
    int notificationCount = 0,
  }) {
    return CustomAppBar(
      title: 'Subscriptions',
      style: CustomAppBarStyle.large,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        onPressed:
            onMenuPressed ??
            () {
              Scaffold.of(context).openDrawer();
            },
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: onNotificationPressed,
            ),
            if (notificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    notificationCount > 9 ? '9+' : '$notificationCount',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onError,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Detail screen app bar with back button and actions
  static CustomAppBar detail({
    required String title,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
  }) {
    return CustomAppBar(
      title: title,
      style: CustomAppBarStyle.standard,
      automaticallyImplyLeading: true,
      onBackPressed: onBackPressed,
      actions: actions,
    );
  }

  /// Search app bar with search field
  static CustomAppBar search({
    required ValueChanged<String> onSearchChanged,
    String searchHint = 'Search subscriptions...',
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      style: CustomAppBarStyle.search,
      onSearchChanged: onSearchChanged,
      searchHint: searchHint,
      actions: actions,
    );
  }

  /// Transparent app bar for overlay contexts
  static CustomAppBar transparent({
    List<Widget>? actions,
    VoidCallback? onBackPressed,
  }) {
    return CustomAppBar(
      style: CustomAppBarStyle.transparent,
      automaticallyImplyLeading: true,
      onBackPressed: onBackPressed,
      actions: actions,
    );
  }
}
