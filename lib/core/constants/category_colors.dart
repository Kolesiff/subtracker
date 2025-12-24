import 'package:flutter/material.dart';
import '../../data/models/subscription.dart';

/// Maps subscription categories to brand colors
///
/// Used for auto-assigning colors when adding new subscriptions.
/// Colors are chosen to be visually distinct and associated with
/// common brands in each category.
class CategoryColors {
  CategoryColors._();

  /// Brand color mapping for each subscription category
  static const Map<SubscriptionCategory, Color> brandColors = {
    SubscriptionCategory.entertainment: Color(0xFFE74C3C), // Netflix red
    SubscriptionCategory.music: Color(0xFF1DB954), // Spotify green
    SubscriptionCategory.productivity: Color(0xFF4A90A4), // Professional blue
    SubscriptionCategory.shopping: Color(0xFFFF9900), // Amazon orange
    SubscriptionCategory.development: Color(0xFF6E5494), // GitHub purple
    SubscriptionCategory.health: Color(0xFF2ECC71), // Health green
    SubscriptionCategory.professional: Color(0xFF0077B5), // LinkedIn blue
    SubscriptionCategory.education: Color(0xFF00A4E4), // Education blue
    SubscriptionCategory.utilities: Color(0xFF7F8C8D), // Neutral gray
    SubscriptionCategory.other: Color(0xFF1B365D), // App primary blue
  };

  /// Default color when category not found
  static const Color defaultColor = Color(0xFF1B365D);

  /// Get brand color for a category
  ///
  /// Returns the mapped color for the category, or [defaultColor] if not found.
  static Color getColor(SubscriptionCategory category) {
    return brandColors[category] ?? defaultColor;
  }

  /// Get brand color for a category name string
  ///
  /// Parses the category name and returns the corresponding color.
  static Color getColorFromString(String categoryName) {
    final category = SubscriptionCategory.fromString(categoryName);
    return getColor(category);
  }
}
