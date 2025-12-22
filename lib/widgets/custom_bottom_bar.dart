import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Navigation item configuration for the bottom navigation bar
enum CustomBottomBarItem { dashboard, trials, add, analytics }

/// Custom bottom navigation bar widget for subscription tracking app
/// Implements thumb-optimized bottom placement with native platform conventions
/// Supports gesture-based navigation and haptic feedback
class CustomBottomBar extends StatefulWidget {
  /// Current selected navigation item
  final CustomBottomBarItem currentItem;

  /// Callback when navigation item is tapped
  final ValueChanged<CustomBottomBarItem> onItemSelected;

  /// Whether to show labels for all items (default: true)
  final bool showLabels;

  /// Custom elevation for the bottom bar (default: 8.0)
  final double elevation;

  /// Whether to enable haptic feedback on tap (default: true)
  final bool enableHapticFeedback;

  const CustomBottomBar({
    super.key,
    required this.currentItem,
    required this.onItemSelected,
    this.showLabels = true,
    this.elevation = 8.0,
    this.enableHapticFeedback = true,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  CustomBottomBarItem? _lastTappedItem;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Handle navigation item tap with animation and haptic feedback
  void _handleItemTap(CustomBottomBarItem item) {
    if (item == widget.currentItem) return;

    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }

    setState(() {
      _lastTappedItem = item;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    widget.onItemSelected(item);
    // Navigation is handled by the parent widget via onItemSelected callback
    // DO NOT call Navigator directly here - it causes double navigation
  }

  /// Get icon for navigation item
  IconData _getIcon(CustomBottomBarItem item, bool isSelected) {
    switch (item) {
      case CustomBottomBarItem.dashboard:
        return isSelected ? Icons.dashboard_rounded : Icons.dashboard_outlined;
      case CustomBottomBarItem.trials:
        return isSelected ? Icons.timer_rounded : Icons.timer_outlined;
      case CustomBottomBarItem.add:
        return Icons.add_circle_rounded;
      case CustomBottomBarItem.analytics:
        return isSelected ? Icons.analytics_rounded : Icons.analytics_outlined;
    }
  }

  /// Get label for navigation item
  String _getLabel(CustomBottomBarItem item) {
    switch (item) {
      case CustomBottomBarItem.dashboard:
        return 'Dashboard';
      case CustomBottomBarItem.trials:
        return 'Trials';
      case CustomBottomBarItem.add:
        return 'Add';
      case CustomBottomBarItem.analytics:
        return 'Analytics';
    }
  }

  /// Build individual navigation item
  Widget _buildNavItem(CustomBottomBarItem item) {
    final isSelected = widget.currentItem == item;
    final isAddButton = item == CustomBottomBarItem.add;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final color = isSelected
        ? (isAddButton ? colorScheme.tertiary : colorScheme.primary)
        : theme.bottomNavigationBarTheme.unselectedItemColor ??
              colorScheme.onSurfaceVariant;

    final icon = _getIcon(item, isSelected);
    final label = _getLabel(item);

    // Special styling for Add button - wrapped in Expanded like other items
    if (isAddButton) {
      return Expanded(
        child: ScaleTransition(
          scale: _lastTappedItem == item
              ? _scaleAnimation
              : const AlwaysStoppedAnimation(1.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleItemTap(item),
              customBorder: const CircleBorder(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 22, color: colorScheme.tertiary),
                  ),
                  if (widget.showLabels) ...[
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Standard navigation items
    return Expanded(
      child: ScaleTransition(
        scale: _lastTappedItem == item
            ? _scaleAnimation
            : const AlwaysStoppedAnimation(1.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleItemTap(item),
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: isSelected ? 26 : 24, color: color),
                if (widget.showLabels) ...[
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomNavTheme = theme.bottomNavigationBarTheme;

    return Container(
      decoration: BoxDecoration(
        color: bottomNavTheme.backgroundColor ?? colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: widget.elevation,
            offset: Offset(0, -widget.elevation / 2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavItem(CustomBottomBarItem.dashboard),
              _buildNavItem(CustomBottomBarItem.trials),
              _buildNavItem(CustomBottomBarItem.add),
              _buildNavItem(CustomBottomBarItem.analytics),
            ],
          ),
        ),
      ),
    );
  }
}

/// Extension to easily use CustomBottomBar in screens
extension CustomBottomBarExtension on Widget {
  /// Wrap the widget with a Scaffold that includes CustomBottomBar
  Widget withBottomBar({
    required CustomBottomBarItem currentItem,
    required ValueChanged<CustomBottomBarItem> onItemSelected,
    bool showLabels = true,
    double elevation = 8.0,
    bool enableHapticFeedback = true,
  }) {
    return Builder(
      builder: (context) => Scaffold(
        body: this,
        bottomNavigationBar: CustomBottomBar(
          currentItem: currentItem,
          onItemSelected: onItemSelected,
          showLabels: showLabels,
          elevation: elevation,
          enableHapticFeedback: enableHapticFeedback,
        ),
      ),
    );
  }
}
