import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Social login options widget
/// Provides Google and Apple sign-in buttons with platform-appropriate styling
class SocialLoginWidget extends StatelessWidget {
  final Function(String provider) onSocialLogin;

  const SocialLoginWidget({super.key, required this.onSocialLogin});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Google Sign In Button
        _buildSocialButton(
          context: context,
          label: 'Continue with Google',
          icon: Icons.g_mobiledata,
          onPressed: () => onSocialLogin('Google'),
          color: const Color(0xFF4285F4),
        ),

        SizedBox(height: 2.h),

        // Apple Sign In Button
        _buildSocialButton(
          context: context,
          label: 'Continue with Apple',
          icon: Icons.apple,
          onPressed: () => onSocialLogin('Apple'),
          color: const Color(0xFF000000),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 6.h),
        side: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 3.h),
          SizedBox(width: 3.w),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
