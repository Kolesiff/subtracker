import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/camera_scanner_widget.dart';
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

  // Form validation
  bool _isFormValid = false;
  bool _isDraft = false;

  // Popular services data
  final List<Map<String, dynamic>> _popularServices = [
    {
      'name': 'Netflix',
      'logo':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1a52c1897-1764720017896.png',
      'semanticLabel': 'Netflix logo with red background and white text',
      'defaultCost': 15.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Entertainment',
    },
    {
      'name': 'Spotify',
      'logo':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1d71ebfa2-1764751041051.png',
      'semanticLabel':
          'Spotify logo with green circular icon on black background',
      'defaultCost': 9.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Entertainment',
    },
    {
      'name': 'Amazon Prime',
      'logo':
          'https://img.rocket.new/generatedImages/rocket_gen_img_112fbd955-1765343832518.png',
      'semanticLabel':
          'Amazon Prime logo with blue shopping cart and smile arrow',
      'defaultCost': 14.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Shopping',
    },
    {
      'name': 'Adobe Creative',
      'logo':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1c8eec6ea-1764647363957.png',
      'semanticLabel': 'Adobe Creative Cloud logo with red gradient background',
      'defaultCost': 54.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Productivity',
    },
    {
      'name': 'Microsoft 365',
      'logo':
          'https://img.rocket.new/generatedImages/rocket_gen_img_15a39e0e6-1764677216261.png',
      'semanticLabel':
          'Microsoft 365 logo with colorful square tiles on white background',
      'defaultCost': 6.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Productivity',
    },
    {
      'name': 'YouTube Premium',
      'logo':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1cf52285e-1764675872914.png',
      'semanticLabel': 'YouTube Premium logo with red play button icon',
      'defaultCost': 11.99,
      'billingCycle': BillingCycle.monthly,
      'category': 'Entertainment',
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
      _selectedInputMethod = InputMethod.manual;
    });
    HapticFeedback.mediumImpact();
  }

  /// Handle camera scan result
  void _onScanComplete(Map<String, dynamic> scanData) {
    setState(() {
      if (scanData['serviceName'] != null) {
        _serviceNameController.text = scanData['serviceName'] as String;
      }
      if (scanData['cost'] != null) {
        _costController.text = (scanData['cost'] as double).toString();
      }
      if (scanData['billingCycle'] != null) {
        _selectedBillingCycle = scanData['billingCycle'] as BillingCycle;
      }
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

  /// Save subscription
  Future<void> _saveSubscription() async {
    if (!_isFormValid) return;

    // Check for duplicates
    final hasDuplicate = await _checkDuplicate();
    if (hasDuplicate) {
      final shouldContinue = await _showDuplicateDialog();
      if (!shouldContinue) return;
    }

    // Simulate saving
    await Future.delayed(const Duration(milliseconds: 800));

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

      // Return to dashboard with new subscription highlighted
      Navigator.pushReplacementNamed(context, '/subscription-dashboard');
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
              ] else if (_selectedInputMethod == InputMethod.camera) ...[
                CameraScannerWidget(
                  onScanComplete: _onScanComplete,
                  onCancel: () {
                    setState(() {
                      _selectedInputMethod = InputMethod.manual;
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
enum InputMethod { manual, camera, service }

/// Billing cycle enum
enum BillingCycle { monthly, yearly, custom }
