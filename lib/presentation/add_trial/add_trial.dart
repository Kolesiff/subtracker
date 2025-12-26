import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/app_export.dart';
import '../../data/constants/popular_trials.dart';
import '../../data/models/subscription.dart';
import '../../data/models/trial.dart';
import '../trial_tracker/viewmodel/trial_viewmodel.dart';
import './widgets/trial_input_method_selector.dart';
import './widgets/popular_trials_grid_widget.dart';
import './widgets/trial_duration_selector.dart';

/// Screen for adding a new trial subscription
class AddTrial extends StatefulWidget {
  const AddTrial({super.key});

  @override
  State<AddTrial> createState() => _AddTrialState();
}

class _AddTrialState extends State<AddTrial> {
  // Input method
  TrialInputMethod _selectedInputMethod = TrialInputMethod.manual;

  // Form controllers
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _cancellationUrlController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Form state
  SubscriptionCategory _selectedCategory = SubscriptionCategory.entertainment;
  TrialDuration _selectedDuration = TrialDuration.sevenDays;
  DateTime _trialEndDate = DateTime.now().add(const Duration(days: 7));
  String? _selectedLogoUrl;

  // Validation and save state
  bool _isFormValid = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _serviceNameController.addListener(_validateForm);
    _costController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _costController.dispose();
    _cancellationUrlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Validate form fields
  void _validateForm() {
    final isValid = _serviceNameController.text.trim().isNotEmpty &&
        _costController.text.trim().isNotEmpty &&
        double.tryParse(_costController.text.trim()) != null;

    if (isValid != _isFormValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  /// Handle duration change
  void _handleDurationChange(TrialDuration duration) {
    setState(() {
      _selectedDuration = duration;
      switch (duration) {
        case TrialDuration.sevenDays:
          _trialEndDate = DateTime.now().add(const Duration(days: 7));
          break;
        case TrialDuration.thirtyDays:
          _trialEndDate = DateTime.now().add(const Duration(days: 30));
          break;
        case TrialDuration.custom:
          // Keep current date for custom
          break;
      }
    });
  }

  /// Handle popular service selection
  void _handleServiceSelected(Map<String, dynamic> service) {
    setState(() {
      _serviceNameController.text = service['name'] as String;
      _costController.text = (service['defaultCost'] as double).toString();
      _selectedCategory = service['category'] as SubscriptionCategory;
      _selectedLogoUrl = service['logo'] as String;

      // Set trial duration based on service's typical trial
      final trialDays = service['trialDays'] as int;
      if (trialDays == 7) {
        _selectedDuration = TrialDuration.sevenDays;
        _trialEndDate = DateTime.now().add(const Duration(days: 7));
      } else if (trialDays == 30) {
        _selectedDuration = TrialDuration.thirtyDays;
        _trialEndDate = DateTime.now().add(const Duration(days: 30));
      } else if (trialDays > 0) {
        _selectedDuration = TrialDuration.custom;
        _trialEndDate = DateTime.now().add(Duration(days: trialDays));
      } else {
        _selectedDuration = TrialDuration.sevenDays;
        _trialEndDate = DateTime.now().add(const Duration(days: 7));
      }

      // Switch to manual tab to show the filled form
      _selectedInputMethod = TrialInputMethod.manual;
    });
    _validateForm();
    HapticFeedback.mediumImpact();
  }

  /// Save trial to Supabase via TrialViewModel
  Future<void> _saveTrial() async {
    if (!_isFormValid || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final viewModel = context.read<TrialViewModel>();

      final trial = Trial(
        id: const Uuid().v4(),
        serviceName: _serviceNameController.text.trim(),
        category: _selectedCategory,
        trialEndDate: _trialEndDate,
        conversionCost: double.parse(_costController.text.trim()),
        cancellationDifficulty: CancellationDifficulty.easy, // Default value
        cancellationUrl: _cancellationUrlController.text.trim().isEmpty
            ? null
            : _cancellationUrlController.text.trim(),
        createdAt: DateTime.now(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        logoUrl: _selectedLogoUrl,
      );

      await viewModel.addTrial(trial);

      HapticFeedback.mediumImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Trial added successfully',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to add trial: ${e.toString()}',
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
        setState(() => _isSaving = false);
      }
    }
  }

  /// Select custom trial end date
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _trialEndDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
      setState(() => _trialEndDate = picked);
      HapticFeedback.lightImpact();
    }
  }

  /// Check if form has unsaved changes
  bool _hasUnsavedChanges() {
    return _serviceNameController.text.isNotEmpty ||
        _costController.text.isNotEmpty ||
        _notesController.text.isNotEmpty ||
        _cancellationUrlController.text.isNotEmpty;
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
            'Add Trial',
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
                onPressed: _isFormValid ? _saveTrial : null,
                child: Text(
                  'Save',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: _isFormValid
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Input method selector
              TrialInputMethodSelector(
                selectedMethod: _selectedInputMethod,
                onMethodChanged: (method) {
                  setState(() => _selectedInputMethod = method);
                  HapticFeedback.lightImpact();
                },
              ),

              // Content based on selected method
              Expanded(
                child: _selectedInputMethod == TrialInputMethod.popular
                    ? _buildPopularTrialsContent()
                    : _buildManualFormContent(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build popular trials grid
  Widget _buildPopularTrialsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: PopularTrialsGridWidget(
        services: PopularTrials.services,
        onServiceSelected: _handleServiceSelected,
      ),
    );
  }

  /// Build manual form content
  Widget _buildManualFormContent(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Name
          Text('Service Name', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _serviceNameController,
            decoration: InputDecoration(
              hintText: 'e.g., Netflix, Spotify',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textCapitalization: TextCapitalization.words,
          ),

          const SizedBox(height: 24),

          // Category Dropdown
          Text('Category', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<SubscriptionCategory>(
            value: _selectedCategory,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: SubscriptionCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category.displayName),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCategory = value);
                HapticFeedback.lightImpact();
              }
            },
          ),

          const SizedBox(height: 24),

          // Trial Duration Selector (replaces CancellationDifficulty)
          TrialDurationSelector(
            selectedDuration: _selectedDuration,
            trialEndDate: _trialEndDate,
            onDurationChanged: _handleDurationChange,
            onCustomDateTap: _selectDate,
          ),

          const SizedBox(height: 24),

          // Conversion Cost
          Text('Conversion Cost (per month)',
              style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _costController,
            decoration: InputDecoration(
              hintText: '0.00',
              prefixText: '\$ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),

          const SizedBox(height: 24),

          // Cancellation URL (optional)
          Text('Cancellation URL (Optional)',
              style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _cancellationUrlController,
            decoration: InputDecoration(
              hintText: 'https://...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.url,
          ),

          const SizedBox(height: 24),

          // Notes (optional)
          Text('Notes (Optional)', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: 'Add any notes about this trial...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
