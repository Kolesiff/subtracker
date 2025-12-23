import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../routes/app_routes.dart';
import './widgets/onboarding_page_widget.dart';

/// Onboarding flow screen that introduces new users to subscription tracking benefits
/// Implements mobile-optimized carousel experience with swipe gestures and skip functionality
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  // Onboarding content data
  final List<Map<String, dynamic>> _onboardingPages = [
    {
      "title": "Never Miss a Trial",
      "description":
          "Track all your free trials in one place and get notified before they convert to paid subscriptions.",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1136bb80f-1765192987750.png",
      "semanticLabel":
          "Smartphone displaying calendar with notification bell icon and trial period countdown timer on blue gradient background",
    },
    {
      "title": "Visualize Your Spending",
      "description":
          "See exactly where your money goes with beautiful charts and detailed breakdowns of all your subscriptions.",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_162e1bb75-1764659449969.png",
      "semanticLabel":
          "Colorful pie chart and bar graphs showing subscription spending categories on tablet screen with financial data visualization",
    },
    {
      "title": "Smart Notifications",
      "description":
          "Get timely reminders before renewals and trial expirations so you're always in control of your subscriptions.",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1136bb80f-1765192987750.png",
      "semanticLabel":
          "Mobile phone with notification bell icon and alert messages showing subscription renewal reminders on dark background",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  /// Handle page change events
  void _onPageChanged() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() {
        _currentPage = page;
        _isLastPage = page == _onboardingPages.length - 1;
      });
      HapticFeedback.lightImpact();
    }
  }

  /// Navigate to next page or complete onboarding
  void _handleNextButton() {
    if (_isLastPage) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Skip onboarding and navigate to dashboard
  void _handleSkip() {
    HapticFeedback.lightImpact();
    _completeOnboarding();
  }

  /// Complete onboarding flow and navigate to login
  Future<void> _completeOnboarding() async {
    // Save onboarding completion status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    // Navigate to login screen (not dashboard)
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            _buildSkipButton(theme),

            // Page view with onboarding content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingPages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                    _isLastPage = index == _onboardingPages.length - 1;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(
                    title: _onboardingPages[index]["title"] as String,
                    description:
                        _onboardingPages[index]["description"] as String,
                    imageUrl: _onboardingPages[index]["image"] as String,
                    semanticLabel:
                        _onboardingPages[index]["semanticLabel"] as String,
                  );
                },
              ),
            ),

            // Page indicator and navigation buttons
            _buildBottomSection(theme),
          ],
        ),
      ),
    );
  }

  /// Build skip button in top-right corner
  Widget _buildSkipButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, right: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: _handleSkip,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: const Size(64, 44),
          ),
          child: Text(
            'Skip',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  /// Build bottom section with page indicator and navigation button
  Widget _buildBottomSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Page indicator dots
          SmoothPageIndicator(
            controller: _pageController,
            count: _onboardingPages.length,
            effect: ExpandingDotsEffect(
              activeDotColor: theme.colorScheme.primary,
              dotColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 4,
              spacing: 8,
            ),
          ),

          const SizedBox(height: 32),

          // Next/Get Started button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleNextButton,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isLastPage ? 'Get Started' : 'Next',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
