import 'package:flutter/foundation.dart';

import '../models/subscription.dart';
import '../models/trial.dart';
import '../services/notification_service.dart';

/// Repository for managing notification scheduling.
/// Provides high-level API for trial and subscription reminders.
abstract class NotificationRepository {
  /// Schedule all reminders for a trial (7, 3, 1 day before)
  Future<void> scheduleTrialReminders(Trial trial);

  /// Cancel all reminders for a specific trial
  Future<void> cancelTrialReminders(String trialId);

  /// Schedule reminder for a subscription (3 days before billing)
  Future<void> scheduleSubscriptionReminders(Subscription subscription);

  /// Cancel reminders for a specific subscription
  Future<void> cancelSubscriptionReminders(String subscriptionId);

  /// Reschedule all notifications for given trials and subscriptions
  Future<void> rescheduleAllNotifications({
    required List<Trial> trials,
    required List<Subscription> subscriptions,
  });

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications();

  /// Check if notifications are currently enabled
  Future<bool> areNotificationsEnabled();

  /// Request notification permissions
  Future<bool> requestPermissions();
}

/// Implementation of NotificationRepository using NotificationService
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationService _service;

  NotificationRepositoryImpl({NotificationService? service})
      : _service = service ?? NotificationService();

  /// Trial notification timing: 7 days, 3 days, 1 day before
  static const List<int> _trialReminderDays = [7, 3, 1];

  /// Subscription notification timing: 3 days before
  static const List<int> _subscriptionReminderDays = [3];

  @override
  Future<void> scheduleTrialReminders(Trial trial) async {
    // Don't schedule if notifications are disabled for this trial
    if (!trial.isNotificationEnabled) {
      debugPrint('Notifications disabled for trial ${trial.id}');
      return;
    }

    // Don't schedule for expired trials
    if (trial.isExpired) {
      debugPrint('Trial ${trial.id} is expired, skipping notifications');
      return;
    }

    for (final daysBefore in _trialReminderDays) {
      final scheduledDate = trial.trialEndDate.subtract(Duration(days: daysBefore));

      // Skip if date is in the past
      if (scheduledDate.isBefore(DateTime.now())) {
        continue;
      }

      final notificationId = NotificationService.generateId('trial_${daysBefore}_${trial.id}');
      final title = _getTrialNotificationTitle(daysBefore);
      final body = _getTrialNotificationBody(trial.serviceName, daysBefore);

      await _service.scheduleNotification(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        payload: 'trial:${trial.id}',
      );
    }

    debugPrint('Scheduled ${_trialReminderDays.length} reminders for trial ${trial.id}');
  }

  String _getTrialNotificationTitle(int daysBefore) {
    if (daysBefore == 1) {
      return 'Trial expires tomorrow!';
    } else if (daysBefore == 3) {
      return 'Trial ending soon';
    } else {
      return 'Trial reminder';
    }
  }

  String _getTrialNotificationBody(String serviceName, int daysBefore) {
    if (daysBefore == 1) {
      return 'Your $serviceName trial ends tomorrow. Cancel now to avoid charges.';
    } else if (daysBefore == 3) {
      return 'Your $serviceName trial ends in 3 days. Remember to cancel if you don\'t want to be charged.';
    } else {
      return 'Your $serviceName trial ends in $daysBefore days.';
    }
  }

  @override
  Future<void> cancelTrialReminders(String trialId) async {
    for (final daysBefore in _trialReminderDays) {
      final notificationId = NotificationService.generateId('trial_${daysBefore}_$trialId');
      await _service.cancelNotification(notificationId);
    }
    debugPrint('Cancelled all reminders for trial $trialId');
  }

  @override
  Future<void> scheduleSubscriptionReminders(Subscription subscription) async {
    // Don't schedule for cancelled or expired subscriptions
    if (subscription.status == SubscriptionStatus.cancelled ||
        subscription.status == SubscriptionStatus.expired) {
      debugPrint('Subscription ${subscription.id} is cancelled/expired, skipping notifications');
      return;
    }

    for (final daysBefore in _subscriptionReminderDays) {
      final scheduledDate = subscription.nextBillingDate.subtract(Duration(days: daysBefore));

      // Skip if date is in the past
      if (scheduledDate.isBefore(DateTime.now())) {
        continue;
      }

      final notificationId = NotificationService.generateId('sub_${daysBefore}_${subscription.id}');
      final title = 'Subscription renewal reminder';
      final body = 'Your ${subscription.name} subscription renews in $daysBefore days (${subscription.formattedCost}).';

      await _service.scheduleNotification(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        payload: 'subscription:${subscription.id}',
      );
    }

    debugPrint('Scheduled ${_subscriptionReminderDays.length} reminders for subscription ${subscription.id}');
  }

  @override
  Future<void> cancelSubscriptionReminders(String subscriptionId) async {
    for (final daysBefore in _subscriptionReminderDays) {
      final notificationId = NotificationService.generateId('sub_${daysBefore}_$subscriptionId');
      await _service.cancelNotification(notificationId);
    }
    debugPrint('Cancelled all reminders for subscription $subscriptionId');
  }

  @override
  Future<void> rescheduleAllNotifications({
    required List<Trial> trials,
    required List<Subscription> subscriptions,
  }) async {
    // Cancel all existing notifications first
    await _service.cancelAllNotifications();

    // Schedule trial reminders
    for (final trial in trials) {
      await scheduleTrialReminders(trial);
    }

    // Schedule subscription reminders
    for (final subscription in subscriptions) {
      await scheduleSubscriptionReminders(subscription);
    }

    debugPrint('Rescheduled notifications for ${trials.length} trials and ${subscriptions.length} subscriptions');
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _service.cancelAllNotifications();
    debugPrint('Cancelled all notifications');
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    return await _service.areNotificationsEnabled();
  }

  @override
  Future<bool> requestPermissions() async {
    return await _service.requestPermissions();
  }
}
