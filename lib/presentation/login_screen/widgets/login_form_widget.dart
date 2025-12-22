import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Login form widget with email and password fields
/// Includes validation, show/hide password toggle, and remember me option
class LoginFormWidget extends StatefulWidget {
  final VoidCallback onLogin;
  final bool isLoading;

  const LoginFormWidget({
    super.key,
    required this.onLogin,
    this.isLoading = false,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _validateAndSubmit() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    bool isValid = true;

    // Email validation
    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = 'Email is required';
      });
      isValid = false;
    } else if (!_isValidEmail(_emailController.text)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      isValid = false;
    }

    // Password validation
    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Password is required';
      });
      isValid = false;
    } else if (_passwordController.text.length < 6) {
      setState(() {
        _passwordError = 'Password must be at least 6 characters';
      });
      isValid = false;
    }

    if (isValid) {
      widget.onLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Input Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: Icon(
                Icons.email_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              errorText: _emailError,
            ),
            onChanged: (_) {
              if (_emailError != null) {
                setState(() {
                  _emailError = null;
                });
              }
            },
          ),

          SizedBox(height: 2.h),

          // Password Input Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
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
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              errorText: _passwordError,
            ),
            onChanged: (_) {
              if (_passwordError != null) {
                setState(() {
                  _passwordError = null;
                });
              }
            },
            onFieldSubmitted: (_) => _validateAndSubmit(),
          ),

          SizedBox(height: 1.h),

          // Remember Me Checkbox
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
              ),
              Text(
                'Remember Me',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Sign In Button
          ElevatedButton(
            onPressed: widget.isLoading ? null : _validateAndSubmit,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 6.h),
            ),
            child: widget.isLoading
                ? SizedBox(
                    height: 2.5.h,
                    width: 2.5.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
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
    );
  }
}
