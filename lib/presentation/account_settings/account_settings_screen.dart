import 'package:flutter/material.dart';

import '../../widgets/custom_bottom_bar.dart';

/// Account Settings Screen - Placeholder
/// TODO: Replace with user-provided implementation
class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  void _handleBottomNavTap(BuildContext context, CustomBottomBarItem item) {
    switch (item) {
      case CustomBottomBarItem.dashboard:
        Navigator.pushReplacementNamed(context, '/subscription-dashboard');
        break;
      case CustomBottomBarItem.trials:
        Navigator.pushReplacementNamed(context, '/trial-tracker');
        break;
      case CustomBottomBarItem.account:
        // Already on account settings
        break;
      case CustomBottomBarItem.analytics:
        Navigator.pushReplacementNamed(context, '/analytics');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text(
          'Account Settings\n(Placeholder - Replace with your implementation)',
          textAlign: TextAlign.center,
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentItem: CustomBottomBarItem.account,
        onItemSelected: (item) => _handleBottomNavTap(context, item),
      ),
    );
  }
}
