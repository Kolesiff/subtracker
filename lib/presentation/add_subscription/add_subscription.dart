import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/app_export.dart';
import '../../data/models/subscription.dart' as models;
import '../subscription_dashboard/viewmodel/dashboard_viewmodel.dart';
import './widgets/input_method_selector_widget.dart';
import './widgets/manual_form_widget.dart';
import './widgets/popular_services_grid_widget.dart';

/// Add Subscription screen for manual entry or automated detection of new subscriptions
/// Implements mobile-optimized input methods with camera scanning and service selection
class AddSubscription extends StatefulWidget {
  const AddSubscription({super.key});

  @override
  State<AddSubscription> createState() => _AddSubscriptionState();
}

class _AddSubscriptionState extends State<AddSubscription> {
  // Input method selection
  InputMethod _selectedInputMethod = InputMethod.manual;

  // Form controllers
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Form state
  String _selectedCurrency = '\$';
  BillingCycle _selectedBillingCycle = BillingCycle.monthly;
  DateTime _nextBillingDate = DateTime.now().add(const Duration(days: 30));
  String _selectedCategory = 'Entertainment';
  int _customAlertDays = 3;
  DateTime? _trialEndDate;
  bool _isTrialSubscription = false;
  String? _selectedLogoUrl;

  // Form validation
  bool _isFormValid = false;
  bool _isDraft = false;

  // Save state
  bool _isSaving = false;

  // Popular services data - using Google Play Store icons (reliable PNGs)
  final List<Map<String, dynamic>> _popularServices = [
    // Entertainment - Streaming
    {
      'name': 'Netflix',
      'logo': 'https://play-lh.googleusercontent.com/TBRwjS_qfJCSj1m7zZB93FnpJM5fSpMA_wUlFDLxWAb45T9RmwBvQd5cWR5viJJOhkI',
      'semanticLabel': 'Netflix logo',
      'defaultCost': 15.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Entertainment',
    },
    {
      'name': 'Spotify',
      'logo': 'https://play-lh.googleusercontent.com/cShys-AmJ93dB0SV8kE6Fl5eSaf4-qMMZdwEDKI5VEmKAXfzOqbiaeAsqqrEBCTdIEs',
      'semanticLabel': 'Spotify logo',
      'defaultCost': 11.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Entertainment',
    },
    {
      'name': 'Disney+',
      'logo': 'https://play-lh.googleusercontent.com/xoGGYH2LgLibLDBoxMg-ZE16b-RNfITw_OgXBWRAPin2FZY4FGB9QKBYApR-0rSCkQ',
      'semanticLabel': 'Disney Plus logo',
      'defaultCost': 13.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Entertainment',
    },
    {
      'name': 'Max',
      'logo': 'https://play-lh.googleusercontent.com/1iyX7VdQ7MlM7iotI9XDtTwgiVmqFGzqwz10L67XVoyiTmJVoHX87QtqvcXgUnb0AC8',
      'semanticLabel': 'Max logo',
      'defaultCost': 15.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Entertainment',
    },
    {
      'name': 'YouTube Premium',
      'logo': 'https://play-lh.googleusercontent.com/lMoItBgdPPVDJsNOVtP26EKHePkwBg-PkuY9NOrc-fumRtTFP4XhpUNk_22syN4Datc',
      'semanticLabel': 'YouTube logo',
      'defaultCost': 13.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Entertainment',
    },
    {
      'name': 'Apple Music',
      'logo': 'https://play-lh.googleusercontent.com/mOkjjo5Rzcpk7BsHrsLWnqVadUK1FlLd2-UlQvYkLL4E9A0LpyODNIQinXPfUMjUrbE',
      'semanticLabel': 'Apple Music logo',
      'defaultCost': 10.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Entertainment',
    },
    {
      'name': 'Amazon Prime Video',
      'logo': 'https://play-lh.googleusercontent.com/mZ4BvGxLeE4gfCpAH3vbnkQ_fFfMw3SfdT6dQXzKWPdCHi2OERFrPHYTp5PKzj4jqkM',
      'semanticLabel': 'Amazon Prime Video logo',
      'defaultCost': 14.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Entertainment',
    },
    {
      'name': 'Hulu',
      'logo': 'https://play-lh.googleusercontent.com/Y9IVBLaVoOhkJvnBo-uqgwvXvHqY8VPZAyHrL_mAaQ0zEOnH8qKYvG3FnLNpBAoG-g',
      'semanticLabel': 'Hulu logo',
      'defaultCost': 17.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Entertainment',
    },
    {
      'name': 'Peacock',
      'logo': 'https://play-lh.googleusercontent.com/siyplYOLKzlxRdU2rSS7gxvP-N4D8xHQf-7oGk1LqhHAowwqLqRn4dR9T4L2xhjlCdM',
      'semanticLabel': 'Peacock logo',
      'defaultCost': 7.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Entertainment',
    },
    {
      'name': 'Paramount+',
      'logo': 'https://play-lh.googleusercontent.com/MKBx2-sVfPtBxylSDOViZ6kK4_svUnHlgQGS9gXBH1uwKbFf3_BYLJFHCuLJO3JB3JY',
      'semanticLabel': 'Paramount Plus logo',
      'defaultCost': 11.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Entertainment',
    },
    {
      'name': 'Crunchyroll',
      'logo': 'https://play-lh.googleusercontent.com/xGUKBx2m-4pWDaIzp1FvYApRi8SvTz7QGmCLFtHzOPvbJc9nyp5VXEABJLjVfDmjLw',
      'semanticLabel': 'Crunchyroll logo',
      'defaultCost': 7.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Entertainment',
    },
    {
      'name': 'Twitch',
      'logo': 'https://play-lh.googleusercontent.com/PoHuonmKmLvPuV_QdC6TLvpqAXlC2cqKxtHiHAPcFRBldmBCNEdGJb1MsKfaFLr0QQ',
      'semanticLabel': 'Twitch logo',
      'defaultCost': 8.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Entertainment',
    },
    // Productivity
    {
      'name': 'Microsoft 365',
      'logo': 'https://play-lh.googleusercontent.com/D6XDCje7pB0nNP1sOZkwD-tXkV0_As3ni21us5mMILPO_Jt4dOax9pVv5YnBwCVUbBM',
      'semanticLabel': 'Microsoft 365 logo',
      'defaultCost': 9.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Productivity',
    },
    {
      'name': 'Notion',
      'logo': 'https://play-lh.googleusercontent.com/PFLuWajA_oegNrJG7oLzQmlOLCXWRkW2ISPLMcOXQFGo5-yBJ3P7EtIZH-TYxv8OlA',
      'semanticLabel': 'Notion logo',
      'defaultCost': 10.00,
      'billingCycle': BillingCycle.monthly,
      'category': 'Productivity',
    },
    {
      'name': 'Slack',
      'logo': 'https://play-lh.googleusercontent.com/mzJpTCsTW_FuR6YqOPaLHrSEVCSJuXzCljdxnCKhVZMcu6EESZBQTCHxMh8slVtnHqk',
      'semanticLabel': 'Slack logo',
      'defaultCost': 8.75,
      'billingCycle': BillingCycle.monthly,
      'category': 'Productivity',
    },
    {
      'name': 'Zoom',
      'logo': 'https://play-lh.googleusercontent.com/yZgmiimA_JaKVh5Q5oJOSbpSgI1Kp7fhC4hQlQ_fTMU7O4QejH1VY5L6Y_oWlVVXVQ',
      'semanticLabel': 'Zoom logo',
      'defaultCost': 15.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Productivity',
    },
    {
      'name': 'Canva',
      'logo': 'https://play-lh.googleusercontent.com/CjzbMcLbmTswzCGauGQExkFsSHvwjKEeWLbVVJ5MZ4bXYQlP0VeCL6yPkD4-n6ySHUM',
      'semanticLabel': 'Canva logo',
      'defaultCost': 12.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Productivity',
    },
    {
      'name': 'Evernote',
      'logo': 'https://play-lh.googleusercontent.com/mG-mj8FYF8Uc6xv5b2r_hLLK7lLM21WqNFmKuLGsM9EtHJ4BTc5X5A5omHR4Dxgq-Q',
      'semanticLabel': 'Evernote logo',
      'defaultCost': 10.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Productivity',
    },
    // Cloud Storage
    {
      'name': 'Google One',
      'logo': 'https://play-lh.googleusercontent.com/59sN5_tCSpnFKCTGcTBf5Em2v0RXk5T2BW7rF1xQtq69a-b4lLV6Qu6gQ8X0Kj-Guw',
      'semanticLabel': 'Google One logo',
      'defaultCost': 2.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Productivity',
    },
    {
      'name': 'Dropbox',
      'logo': 'https://play-lh.googleusercontent.com/cNcq2_VqfPxMYgNHMmNMkMwlHND5q1zU-K0YQSJ4bPBkF-U3D7fWoC_E4_pPK8qJJw',
      'semanticLabel': 'Dropbox logo',
      'defaultCost': 11.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Productivity',
    },
    {
      'name': 'OneDrive',
      'logo': 'https://play-lh.googleusercontent.com/9Sqr9LcoYh5VL3wIcZpKb5C8R2xExnLTfAO0D5bKZCJj-MeqPjEcRcWMHCyM4RiLwA',
      'semanticLabel': 'OneDrive logo',
      'defaultCost': 1.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Productivity',
    },
    // Gaming
    {
      'name': 'Xbox Game Pass',
      'logo': 'https://play-lh.googleusercontent.com/7j1q3FaTvb4r2QDrZ1J7JNCJ3yI-R7xJxQC8vJlQsGkdKrDVMpBYZ5xBqyPBhJMFRw',
      'semanticLabel': 'Xbox Game Pass logo',
      'defaultCost': 16.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Entertainment',
    },
    {
      'name': 'PlayStation App',
      'logo': 'https://play-lh.googleusercontent.com/tDaMwqdDWTvE6DRUjYQLSPGXJNvJQx6X3sB8y_eBXMoMFFk0XZUJmGFqZ8dJVfKmmQ',
      'semanticLabel': 'PlayStation logo',
      'defaultCost': 17.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Entertainment',
    },
    {
      'name': 'Discord Nitro',
      'logo': 'https://play-lh.googleusercontent.com/0oO5sAneb9lJP6l8c6DH4aj6f85qNpplQVHmPmbbBxAukDnlO7DarDW0b-kEIHa8SQ',
      'semanticLabel': 'Discord logo',
      'defaultCost': 9.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Entertainment',
    },
    // Health & Fitness
    {
      'name': 'Headspace',
      'logo': 'https://play-lh.googleusercontent.com/XyPHKRZnTHJgKE0gI6MKJjh5wJJPR0yoJzrg0YGk0-bALxMRRmGLmZk8QSgF2PYaXMfO',
      'semanticLabel': 'Headspace logo',
      'defaultCost': 12.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Health',
    },
    {
      'name': 'Calm',
      'logo': 'https://play-lh.googleusercontent.com/HZkwYjYJMw0DOZSrZkKjCNgr6M5OxJYmhLD9qQ8IKZvLlvf9L9i3LCClTQwqkI_pCMw',
      'semanticLabel': 'Calm logo',
      'defaultCost': 14.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Health',
    },
    {
      'name': 'Strava',
      'logo': 'https://play-lh.googleusercontent.com/VZVr7A0Gkf8GKKyXb3fI8c0rgH9gN1fJ6gKM-aLzMQqH8PJTgYQwwwQK4gLoxvzL8fk',
      'semanticLabel': 'Strava logo',
      'defaultCost': 11.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Health',
    },
    {
      'name': 'MyFitnessPal',
      'logo': 'https://play-lh.googleusercontent.com/w1UpXK4_QZWmLGFdvUKLTXKrQX9TZC7WG0Fn8cGO4KhHhXV0mMmPSBqJ-gGSF4M3dQ',
      'semanticLabel': 'MyFitnessPal logo',
      'defaultCost': 19.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Health',
    },
    {
      'name': 'Fitbit Premium',
      'logo': 'https://play-lh.googleusercontent.com/PZGF2UMQPY7X3-nGBTmVkqS7xPQe2TZ-vRHEZLN7EJpJPzGqFWpNz8-dK8LqK8q8Kg',
      'semanticLabel': 'Fitbit logo',
      'defaultCost': 9.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Health',
    },
    // Education
    {
      'name': 'Duolingo Plus',
      'logo': 'https://play-lh.googleusercontent.com/9CDH4Gg3CLR4xAvkYNuNfYbIb4U5Hxu8mMYJBmLxGwfMLuQIwXK-aqWqy4n8V0LxuA',
      'semanticLabel': 'Duolingo logo',
      'defaultCost': 12.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Education',
    },
    {
      'name': 'LinkedIn Premium',
      'logo': 'https://play-lh.googleusercontent.com/kMofEFLjobZy_bCuaiDogzBcUT-dz3BBbOrj1kjVVPLf1K91XMZ6N0yl2r8j7_BMOsY',
      'semanticLabel': 'LinkedIn logo',
      'defaultCost': 29.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Education',
    },
    {
      'name': 'Coursera',
      'logo': 'https://play-lh.googleusercontent.com/BdVXzaT3dDDi3dHu7t-GEVfCklMGDy7RZ9j-0q2jYiPNQ7-w5qQZKP0l7L_O7FkJvEM',
      'semanticLabel': 'Coursera logo',
      'defaultCost': 59.00,
      'billingCycle': BillingCycle.monthly,
      'category': 'Education',
    },
    {
      'name': 'Skillshare',
      'logo': 'https://play-lh.googleusercontent.com/Hq6L9P6j6qMBLJPWL2RYhD0Y0HM2E5m5xKlZKxY3V0n0FXCXW5Xp3-1H7U3YdWVxHw',
      'semanticLabel': 'Skillshare logo',
      'defaultCost': 13.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Education',
    },
    // Security & VPN
    {
      'name': '1Password',
      'logo': 'https://play-lh.googleusercontent.com/dz7StpqAcNe_4ZLQC1KSXM2IxM1s0L5J_V4sAJr5wWNPVMvKPKqJN0PBj7m9MXO6Ow',
      'semanticLabel': '1Password logo',
      'defaultCost': 2.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Productivity',
    },
    {
      'name': 'NordVPN',
      'logo': 'https://play-lh.googleusercontent.com/WGGV8jx8L4e-D_2v_eqE-5MiZVRqVQbYVUAf8kF0tLQkLT-hxrfF6RFr0HbFwvVfnYg',
      'semanticLabel': 'NordVPN logo',
      'defaultCost': 12.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Productivity',
    },
    {
      'name': 'ExpressVPN',
      'logo': 'https://play-lh.googleusercontent.com/bQpVx_S0SILq4G1S5qCNGqQMdRR7YkV9dQRhM-2R0vNB6PALTh5L2ZvgXuJl7Cy0FKM',
      'semanticLabel': 'ExpressVPN logo',
      'defaultCost': 12.95,
      'billingCycle': BillingCycle.monthly,
      'category': 'Productivity',
    },
    // Shopping & Delivery
    {
      'name': 'DoorDash',
      'logo': 'https://play-lh.googleusercontent.com/RQWIBZFV7kWlXcxPPTiO1mLJWKv_F_Qd7x4YY5JQv6KQ9WYTJZJfUvZU5Y4CXZVx1w',
      'semanticLabel': 'DoorDash logo',
      'defaultCost': 9.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Shopping',
    },
    {
      'name': 'Uber Eats',
      'logo': 'https://play-lh.googleusercontent.com/HmCp_yKcMIoESvbLMSvLHS4UfT0p25xdOlg9K7WZJK5lCaXgGmXlVs2YbV2D0X5JxQ',
      'semanticLabel': 'Uber Eats logo',
      'defaultCost': 9.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Shopping',
    },
    {
      'name': 'Instacart',
      'logo': 'https://play-lh.googleusercontent.com/YHdVfS_xDx4bM7OiAP7BLbz2cSCVKJPDpVLdLzZDjJPFvbvTwXi_1L4KfGJL7jDMnA',
      'semanticLabel': 'Instacart logo',
      'defaultCost': 9.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Shopping',
    },
    // News & Reading
    {
      'name': 'Audible',
      'logo': 'https://play-lh.googleusercontent.com/VKdLqM3eQ5bOnV9T2Oet1jJOuK7m5D0lEJ3zghbB8OQXqH9jLEYHXjHoNmgQEJ8wGQ',
      'semanticLabel': 'Audible logo',
      'defaultCost': 14.95,
      'billingCycle': BillingCycle.monthly,
      'category': 'Entertainment',
    },
    {
      'name': 'Kindle',
      'logo': 'https://play-lh.googleusercontent.com/X3fOw07L8VQx5JKx7A5_3ooJbJCg-Ck2W0vQZ0y5nWfxoGCnBb_XF7eSnL3RQTJ-8g',
      'semanticLabel': 'Kindle logo',
      'defaultCost': 11.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Entertainment',
    },
    {
      'name': 'Medium',
      'logo': 'https://play-lh.googleusercontent.com/ouJFk1LLAuXmXq8KS_FBWCWGCZ0AJ4LMxrVv8g4C3e3DfZoTPxQu_5r7rHEVJQk-1g',
      'semanticLabel': 'Medium logo',
      'defaultCost': 5.00,
      'billingCycle': BillingCycle.monthly,
      'category': 'News',
    },
  ];

  // Categories with icons
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Entertainment', 'icon': 'movie'},
    {'name': 'Productivity', 'icon': 'work'},
    {'name': 'Health', 'icon': 'favorite'},
    {'name': 'Shopping', 'icon': 'shopping_cart'},
    {'name': 'Education', 'icon': 'school'},
    {'name': 'Finance', 'icon': 'account_balance'},
    {'name': 'News', 'icon': 'article'},
    {'name': 'Other', 'icon': 'more_horiz'},
  ];

  @override
  void initState() {
    super.initState();
    _serviceNameController.addListener(_validateForm);
    _costController.addListener(_validateForm);
    _loadDraft();
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Load draft if exists
  void _loadDraft() {
    // In production, load from local storage
    setState(() {
      _isDraft = false;
    });
  }

  /// Auto-save draft
  void _saveDraft() {
    // In production, save to local storage
    setState(() {
      _isDraft = true;
    });
  }

  /// Validate form fields
  void _validateForm() {
    final isValid =
        _serviceNameController.text.trim().isNotEmpty &&
        _costController.text.trim().isNotEmpty &&
        double.tryParse(_costController.text.trim()) != null;

    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }

    // Auto-save draft on changes
    if (_serviceNameController.text.isNotEmpty ||
        _costController.text.isNotEmpty) {
      _saveDraft();
    }
  }

  /// Handle input method change
  void _onInputMethodChanged(InputMethod method) {
    setState(() {
      _selectedInputMethod = method;
    });
    HapticFeedback.lightImpact();
  }

  /// Handle popular service selection
  void _onServiceSelected(Map<String, dynamic> service) {
    setState(() {
      _serviceNameController.text = service['name'] as String;
      _costController.text = (service['defaultCost'] as double).toString();
      _selectedBillingCycle = service['billingCycle'] as BillingCycle;
      _selectedCategory = service['category'] as String;
      _selectedLogoUrl = service['logo'] as String?;
      _selectedInputMethod = InputMethod.manual;
    });
    HapticFeedback.mediumImpact();
  }

  /// Show category selection bottom sheet
  void _showCategorySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCategoryBottomSheet(),
    );
  }

  /// Build category selection bottom sheet
  Widget _buildCategoryBottomSheet() {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Select Category', style: theme.textTheme.titleLarge),
            ),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category['name'];

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['name'] as String;
                      });
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(
                                  alpha: 0.2,
                                ),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: category['icon'] as String,
                            size: 28,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category['name'] as String,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Show date picker
  Future<void> _selectDate(BuildContext context, bool isTrialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isTrialDate
          ? (_trialEndDate ?? DateTime.now().add(const Duration(days: 7)))
          : _nextBillingDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isTrialDate) {
          _trialEndDate = picked;
        } else {
          _nextBillingDate = picked;
        }
      });
      HapticFeedback.lightImpact();
    }
  }

  /// Check for duplicate subscription
  Future<bool> _checkDuplicate() async {
    // In production, check against existing subscriptions
    // For now, simulate check
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate finding a similar subscription
    final serviceName = _serviceNameController.text.trim().toLowerCase();
    if (serviceName.contains('netflix') || serviceName.contains('spotify')) {
      return true; // Duplicate found
    }

    return false;
  }

  /// Show duplicate confirmation dialog
  Future<bool> _showDuplicateDialog() async {
    final theme = Theme.of(context);

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Similar Subscription Found',
              style: theme.textTheme.titleLarge,
            ),
            content: Text(
              'A subscription with a similar name already exists. Do you want to add it anyway?',
              style: theme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Add Anyway'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Map local category string to SubscriptionCategory enum
  models.SubscriptionCategory _mapCategory(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'entertainment':
        return models.SubscriptionCategory.entertainment;
      case 'productivity':
        return models.SubscriptionCategory.productivity;
      case 'health':
        return models.SubscriptionCategory.health;
      case 'shopping':
        return models.SubscriptionCategory.shopping;
      case 'education':
        return models.SubscriptionCategory.education;
      case 'music':
        return models.SubscriptionCategory.music;
      case 'development':
        return models.SubscriptionCategory.development;
      case 'professional':
        return models.SubscriptionCategory.professional;
      case 'utilities':
        return models.SubscriptionCategory.utilities;
      default:
        return models.SubscriptionCategory.other;
    }
  }

  /// Map local BillingCycle to model BillingCycle
  models.BillingCycle _mapBillingCycle(BillingCycle localCycle) {
    switch (localCycle) {
      case BillingCycle.monthly:
        return models.BillingCycle.monthly;
      case BillingCycle.yearly:
        return models.BillingCycle.yearly;
      case BillingCycle.custom:
        return models.BillingCycle.monthly; // Default custom to monthly
    }
  }

  /// Save subscription to Supabase via DashboardViewModel
  Future<void> _saveSubscription() async {
    if (!_isFormValid || _isSaving) return;

    // Check for duplicates
    final hasDuplicate = await _checkDuplicate();
    if (hasDuplicate) {
      final shouldContinue = await _showDuplicateDialog();
      if (!shouldContinue) return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final viewModel = context.read<DashboardViewModel>();

      // Map local enums to model enums
      final category = _mapCategory(_selectedCategory);
      final billingCycle = _mapBillingCycle(_selectedBillingCycle);

      // Auto-assign brand color based on category
      final brandColor = CategoryColors.getColor(category);

      // Determine status based on trial toggle
      final status = _isTrialSubscription
          ? models.SubscriptionStatus.trial
          : models.SubscriptionStatus.active;

      // Build Subscription object
      final subscription = models.Subscription(
        id: const Uuid().v4(),
        name: _serviceNameController.text.trim(),
        logoUrl: _selectedLogoUrl,
        cost: double.parse(_costController.text.trim()),
        billingCycle: billingCycle,
        nextBillingDate: _nextBillingDate,
        category: category,
        status: status,
        brandColor: brandColor,
        createdAt: DateTime.now(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      // Save to Supabase via ViewModel
      await viewModel.addSubscription(subscription);

      // Success feedback
      HapticFeedback.mediumImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Subscription added successfully',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        // Return to dashboard - subscription will appear via real-time stream
        Navigator.pushReplacementNamed(context, '/subscription-dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to add subscription: ${e.toString()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onError,
                  ),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Check if form has unsaved changes
  bool _hasUnsavedChanges() {
    return _serviceNameController.text.isNotEmpty ||
        _costController.text.isNotEmpty ||
        _notesController.text.isNotEmpty;
  }

  /// Handle cancel action
  void _handleCancel() {
    if (_hasUnsavedChanges()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Discard Changes?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            'You have unsaved changes. Do you want to discard them?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep Editing'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_hasUnsavedChanges(),
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          _handleCancel();
        }
      },
      child: Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'close',
            size: 24,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: _handleCancel,
        ),
        title: Text(
          'Add Subscription',
          style: theme.appBarTheme.titleTextStyle,
        ),
        actions: [
          if (_isSaving)
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
            )
          else
            TextButton(
              onPressed: _isFormValid ? _saveSubscription : null,
              child: Text(
                'Save',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: _isFormValid
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input method selector
              InputMethodSelectorWidget(
                selectedMethod: _selectedInputMethod,
                onMethodChanged: _onInputMethodChanged,
              ),

              const SizedBox(height: 24),

              // Content based on selected input method
              if (_selectedInputMethod == InputMethod.manual) ...[
                ManualFormWidget(
                  serviceNameController: _serviceNameController,
                  costController: _costController,
                  notesController: _notesController,
                  selectedCurrency: _selectedCurrency,
                  selectedBillingCycle: _selectedBillingCycle,
                  nextBillingDate: _nextBillingDate,
                  selectedCategory: _selectedCategory,
                  customAlertDays: _customAlertDays,
                  trialEndDate: _trialEndDate,
                  isTrialSubscription: _isTrialSubscription,
                  onCurrencyChanged: (currency) {
                    setState(() {
                      _selectedCurrency = currency;
                    });
                  },
                  onBillingCycleChanged: (cycle) {
                    setState(() {
                      _selectedBillingCycle = cycle;
                    });
                  },
                  onCategoryTap: _showCategorySelector,
                  onDateSelect: (isTrialDate) =>
                      _selectDate(context, isTrialDate),
                  onAlertDaysChanged: (days) {
                    setState(() {
                      _customAlertDays = days;
                    });
                  },
                  onTrialToggle: (value) {
                    setState(() {
                      _isTrialSubscription = value;
                      if (!value) {
                        _trialEndDate = null;
                      }
                    });
                  },
                ),
              ] else if (_selectedInputMethod == InputMethod.service) ...[
                PopularServicesGridWidget(
                  services: _popularServices,
                  onServiceSelected: _onServiceSelected,
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

/// Input method enum
enum InputMethod { manual, service }

/// Billing cycle enum
enum BillingCycle { monthly, yearly, custom }
