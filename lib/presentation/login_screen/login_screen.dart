import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import './widgets/login_form_widget.dart';
import './widgets/social_login_widget.dart';

/// Login Screen for returning users to access their subscription data
/// Features: Email/Password authentication, social login options, biometric prompt
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  void _handleLogin() {
    setState(() {
      _isLoading = true;
    });

    // Simulate authentication (UI-only mock-up)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Navigate to dashboard after successful "login"
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.subscriptionDashboard,
        );
      }
    });
  }

  void _handleForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset link sent to your email'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleCreateAccount() {
    Navigator.pushReplacementNamed(context, AppRoutes.onboardingFlow);
  }

  void _handleSocialLogin(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Signing in with $provider...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 6.h),

                // App Logo and Header
                _buildHeader(),

                SizedBox(height: 6.h),

                // Login Form
                LoginFormWidget(onLogin: _handleLogin, isLoading: _isLoading),

                SizedBox(height: 2.h),

                // Forgot Password Link
                _buildForgotPasswordLink(),

                SizedBox(height: 3.h),

                // Divider with "OR"
                _buildDivider(),

                SizedBox(height: 3.h),

                // Social Login Options
                SocialLoginWidget(onSocialLogin: _handleSocialLogin),

                SizedBox(height: 4.h),

                // Create Account Button
                _buildCreateAccountButton(),

                SizedBox(height: 3.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Logo
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Icon(
            Icons.subscriptions_rounded,
            size: 10.w,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),

        SizedBox(height: 2.h),

        // Welcome Text
        Text(
          'Welcome Back',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),

        SizedBox(height: 1.h),

        // Tagline
        Text(
          'Sign in to manage your subscriptions',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _handleForgotPassword,
        child: Text(
          'Forgot Password?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Theme.of(context).dividerColor, thickness: 1),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'OR',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: Theme.of(context).dividerColor, thickness: 1),
        ),
      ],
    );
  }

  Widget _buildCreateAccountButton() {
    return Column(
      children: [
        Text(
          "Don't have an account?",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),

        SizedBox(height: 1.h),

        OutlinedButton(
          onPressed: _handleCreateAccount,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(double.infinity, 6.h),
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.5,
            ),
          ),
          child: Text(
            'Create Account',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
