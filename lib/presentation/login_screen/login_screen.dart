import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../routes/app_routes.dart';
import '../auth/viewmodel/auth_viewmodel.dart';
import './widgets/social_login_widget.dart';

/// Login Screen for returning users to access their subscription data
/// Features: Email/Password authentication, signup tab, social login options
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  // Login form controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _loginObscurePassword = true;

  // Signup form controllers
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();
  bool _signupObscurePassword = true;
  bool _signupObscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listen for auth state changes (e.g., from OAuth callback)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<AuthViewModel>();
      viewModel.addListener(_onAuthStateChanged);
      // Also check current status in case already authenticated
      _onAuthStateChanged();
    });
  }

  void _onAuthStateChanged() {
    final viewModel = context.read<AuthViewModel>();
    if (viewModel.status == AuthStatus.authenticated && mounted) {
      // Navigate to dashboard when authenticated (e.g., after OAuth callback)
      Navigator.pushReplacementNamed(context, AppRoutes.subscriptionDashboard);
    }
  }

  @override
  void dispose() {
    // Remove auth listener to prevent memory leaks
    try {
      context.read<AuthViewModel>().removeListener(_onAuthStateChanged);
    } catch (_) {
      // Context may not be available during dispose
    }
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    super.dispose();
  }

  void _handleLogin(AuthViewModel viewModel) async {
    if (_loginFormKey.currentState?.validate() ?? false) {
      await viewModel.signIn(
        email: _loginEmailController.text,
        password: _loginPasswordController.text,
      );

      if (viewModel.status == AuthStatus.authenticated && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.subscriptionDashboard);
      }
    }
  }

  void _handleSignup(AuthViewModel viewModel) async {
    if (_signupFormKey.currentState?.validate() ?? false) {
      await viewModel.signUp(
        email: _signupEmailController.text,
        password: _signupPasswordController.text,
      );

      if (viewModel.status == AuthStatus.authenticated && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.subscriptionDashboard);
      }
    }
  }

  void _handleGoogleSignIn(AuthViewModel viewModel) async {
    await viewModel.signInWithGoogle();

    if (viewModel.status == AuthStatus.authenticated && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.subscriptionDashboard);
    }
  }

  void _handleForgotPassword(AuthViewModel viewModel) async {
    final email = _loginEmailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address first')),
      );
      return;
    }

    await viewModel.resetPassword(email: email);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.status == AuthStatus.success
                ? 'Password reset link sent to your email'
                : viewModel.errorMessage ?? 'Failed to send reset email',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        // Show error if any
        if (viewModel.status == AuthStatus.error && viewModel.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(viewModel.errorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
            viewModel.clearError();
          });
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 4.h),

                    // App Logo and Header
                    _buildHeader(),

                    SizedBox(height: 3.h),

                    // Tab Bar
                    _buildTabBar(),

                    SizedBox(height: 2.h),

                    // Tab Views
                    SizedBox(
                      height: 45.h,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildLoginForm(viewModel),
                          _buildSignupForm(viewModel),
                        ],
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Divider with "OR"
                    _buildDivider(),

                    SizedBox(height: 2.h),

                    // Social Login Options
                    SocialLoginWidget(
                      onSocialLogin: (provider) {
                        if (provider == 'Google') {
                          _handleGoogleSignIn(viewModel);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$provider sign in coming soon')),
                          );
                        }
                      },
                    ),

                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
          'SubTracker',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),

        SizedBox(height: 0.5.h),

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

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Theme.of(context).colorScheme.onPrimary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Sign In'),
          Tab(text: 'Sign Up'),
        ],
      ),
    );
  }

  Widget _buildLoginForm(AuthViewModel viewModel) {
    return Form(
      key: _loginFormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 2.h),

            // Email Field
            TextFormField(
              controller: _loginEmailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              validator: viewModel.validateEmail,
            ),

            SizedBox(height: 2.h),

            // Password Field
            TextFormField(
              controller: _loginPasswordController,
              obscureText: _loginObscurePassword,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _loginObscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    setState(() {
                      _loginObscurePassword = !_loginObscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
              onFieldSubmitted: (_) => _handleLogin(viewModel),
            ),

            SizedBox(height: 1.h),

            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _handleForgotPassword(viewModel),
                child: Text(
                  'Forgot Password?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ),

            SizedBox(height: 2.h),

            // Sign In Button
            ElevatedButton(
              onPressed: viewModel.isLoading ? null : () => _handleLogin(viewModel),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 6.h),
              ),
              child: viewModel.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(
                      'Sign In',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupForm(AuthViewModel viewModel) {
    return Form(
      key: _signupFormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 2.h),

            // Email Field
            TextFormField(
              controller: _signupEmailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              validator: viewModel.validateEmail,
            ),

            SizedBox(height: 2.h),

            // Password Field
            TextFormField(
              controller: _signupPasswordController,
              obscureText: _signupObscurePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Create a password',
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _signupObscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    setState(() {
                      _signupObscurePassword = !_signupObscurePassword;
                    });
                  },
                ),
                helperText: 'Min 8 chars with uppercase, lowercase & number',
                helperMaxLines: 2,
              ),
              validator: viewModel.validatePassword,
            ),

            SizedBox(height: 2.h),

            // Confirm Password Field
            TextFormField(
              controller: _signupConfirmPasswordController,
              obscureText: _signupObscureConfirmPassword,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Confirm your password',
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _signupObscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    setState(() {
                      _signupObscureConfirmPassword = !_signupObscureConfirmPassword;
                    });
                  },
                ),
              ),
              validator: (value) => viewModel.validateConfirmPassword(
                _signupPasswordController.text,
                value,
              ),
              onFieldSubmitted: (_) => _handleSignup(viewModel),
            ),

            SizedBox(height: 3.h),

            // Sign Up Button
            ElevatedButton(
              onPressed: viewModel.isLoading ? null : () => _handleSignup(viewModel),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 6.h),
              ),
              child: viewModel.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
            ),
          ],
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
}
