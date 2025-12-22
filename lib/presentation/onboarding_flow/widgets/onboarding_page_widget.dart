import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_widget.dart';

/// Individual onboarding page widget displaying illustration, title, and description
/// Optimized for mobile reading with large visuals and concise text
class OnboardingPageWidget extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String semanticLabel;

  const OnboardingPageWidget({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large illustration (60% of safe area)
          Flexible(
            flex: 6,
            child: Container(
              constraints: BoxConstraints(maxHeight: 50.h, maxWidth: 80.w),
              child: CustomImageWidget(
                imageUrl: imageUrl,
                width: 80.w,
                height: 50.h,
                fit: BoxFit.contain,
                semanticLabel: semanticLabel,
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // Headline
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 2.h),

          // Description text
          Flexible(
            flex: 2,
            child: Text(
              description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}
