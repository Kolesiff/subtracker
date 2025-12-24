import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/core/constants/category_colors.dart';
import 'package:subtracker/data/models/subscription.dart';

void main() {
  group('CategoryColors', () {
    group('brandColors map', () {
      test('contains all subscription categories', () {
        for (final category in SubscriptionCategory.values) {
          expect(
            CategoryColors.brandColors.containsKey(category),
            isTrue,
            reason: 'Missing color for $category',
          );
        }
      });

      test('all colors are non-transparent', () {
        for (final entry in CategoryColors.brandColors.entries) {
          expect(
            entry.value.alpha,
            equals(255),
            reason: '${entry.key} color should be fully opaque',
          );
        }
      });

      test('entertainment has red color', () {
        expect(
          CategoryColors.brandColors[SubscriptionCategory.entertainment],
          equals(const Color(0xFFE74C3C)),
        );
      });

      test('music has Spotify green color', () {
        expect(
          CategoryColors.brandColors[SubscriptionCategory.music],
          equals(const Color(0xFF1DB954)),
        );
      });

      test('productivity has professional blue color', () {
        expect(
          CategoryColors.brandColors[SubscriptionCategory.productivity],
          equals(const Color(0xFF4A90A4)),
        );
      });

      test('shopping has Amazon orange color', () {
        expect(
          CategoryColors.brandColors[SubscriptionCategory.shopping],
          equals(const Color(0xFFFF9900)),
        );
      });

      test('development has GitHub purple color', () {
        expect(
          CategoryColors.brandColors[SubscriptionCategory.development],
          equals(const Color(0xFF6E5494)),
        );
      });

      test('health has green color', () {
        expect(
          CategoryColors.brandColors[SubscriptionCategory.health],
          equals(const Color(0xFF2ECC71)),
        );
      });

      test('professional has LinkedIn blue color', () {
        expect(
          CategoryColors.brandColors[SubscriptionCategory.professional],
          equals(const Color(0xFF0077B5)),
        );
      });

      test('education has education blue color', () {
        expect(
          CategoryColors.brandColors[SubscriptionCategory.education],
          equals(const Color(0xFF00A4E4)),
        );
      });

      test('utilities has neutral gray color', () {
        expect(
          CategoryColors.brandColors[SubscriptionCategory.utilities],
          equals(const Color(0xFF7F8C8D)),
        );
      });

      test('other has app primary blue color', () {
        expect(
          CategoryColors.brandColors[SubscriptionCategory.other],
          equals(const Color(0xFF1B365D)),
        );
      });
    });

    group('defaultColor', () {
      test('is app primary blue', () {
        expect(
          CategoryColors.defaultColor,
          equals(const Color(0xFF1B365D)),
        );
      });

      test('is fully opaque', () {
        expect(CategoryColors.defaultColor.alpha, equals(255));
      });
    });

    group('getColor', () {
      test('returns correct color for each category', () {
        for (final category in SubscriptionCategory.values) {
          final color = CategoryColors.getColor(category);
          expect(
            color,
            equals(CategoryColors.brandColors[category]),
            reason: 'getColor($category) should match brandColors map',
          );
        }
      });

      test('returns entertainment red for entertainment category', () {
        expect(
          CategoryColors.getColor(SubscriptionCategory.entertainment),
          equals(const Color(0xFFE74C3C)),
        );
      });

      test('returns music green for music category', () {
        expect(
          CategoryColors.getColor(SubscriptionCategory.music),
          equals(const Color(0xFF1DB954)),
        );
      });
    });

    group('getColorFromString', () {
      test('returns correct color for valid category names', () {
        expect(
          CategoryColors.getColorFromString('entertainment'),
          equals(const Color(0xFFE74C3C)),
        );
        expect(
          CategoryColors.getColorFromString('music'),
          equals(const Color(0xFF1DB954)),
        );
        expect(
          CategoryColors.getColorFromString('productivity'),
          equals(const Color(0xFF4A90A4)),
        );
      });

      test('is case insensitive', () {
        expect(
          CategoryColors.getColorFromString('ENTERTAINMENT'),
          equals(const Color(0xFFE74C3C)),
        );
        expect(
          CategoryColors.getColorFromString('Music'),
          equals(const Color(0xFF1DB954)),
        );
        expect(
          CategoryColors.getColorFromString('PRODUCTIVITY'),
          equals(const Color(0xFF4A90A4)),
        );
      });

      test('returns other category color for unknown strings', () {
        expect(
          CategoryColors.getColorFromString('unknown'),
          equals(CategoryColors.brandColors[SubscriptionCategory.other]),
        );
        expect(
          CategoryColors.getColorFromString(''),
          equals(CategoryColors.brandColors[SubscriptionCategory.other]),
        );
        expect(
          CategoryColors.getColorFromString('invalid_category'),
          equals(CategoryColors.brandColors[SubscriptionCategory.other]),
        );
      });
    });

    group('color uniqueness', () {
      test('all category colors are unique', () {
        final colors = CategoryColors.brandColors.values.toList();
        final uniqueColors = colors.toSet();
        expect(
          uniqueColors.length,
          equals(colors.length),
          reason: 'All category colors should be unique',
        );
      });
    });
  });
}
