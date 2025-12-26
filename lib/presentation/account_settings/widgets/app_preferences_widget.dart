import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/user_settings.dart';
import '../../../theme/app_theme.dart';
import '../viewmodel/account_settings_viewmodel.dart';
import 'settings_section_widget.dart';

/// Widget for app preferences (currency)
/// Displays selection tiles that open bottom sheets for choices
class AppPreferencesWidget extends StatelessWidget {
  const AppPreferencesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountSettingsViewModel>(
      builder: (context, viewModel, child) {
        return SettingsSectionWidget(
          title: 'App Preferences',
          children: [
            _buildSelectionTile(
              context: context,
              icon: Icons.attach_money,
              title: 'Currency',
              currentValue: viewModel.currentCurrency,
              onTap: () => _showCurrencySheet(context, viewModel),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String currentValue,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: Text(currentValue, style: Theme.of(context).textTheme.bodySmall),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  void _showCurrencySheet(BuildContext context, AccountSettingsViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Currency',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: SupportedCurrencies.all.length,
                      itemBuilder: (context, index) {
                        final currency = SupportedCurrencies.all[index];
                        final isSelected = viewModel.currentCurrency == currency;
                        return ListTile(
                          title: Text(
                            '$currency - ${SupportedCurrencies.name(currency)}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                          onTap: () {
                            viewModel.updateCurrency(currency);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
