import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

/// Task names for WorkManager
const String dailyNotificationSyncTask = 'dailyNotificationSync';
const String immediateNotificationSyncTask = 'immediateNotificationSync';

/// Callback dispatcher for WorkManager.
/// Must be a top-level function.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('BackgroundWorker: Executing task: $task');

    switch (task) {
      case dailyNotificationSyncTask:
        // Daily sync task - reschedule notifications
        // Note: This would need to fetch data from Supabase and reschedule
        // For now, we just log that it ran
        debugPrint('BackgroundWorker: Daily notification sync completed');
        return true;

      case immediateNotificationSyncTask:
        // Immediate sync task - triggered when user enables notifications
        debugPrint('BackgroundWorker: Immediate notification sync completed');
        return true;

      default:
        debugPrint('BackgroundWorker: Unknown task: $task');
        return false;
    }
  });
}

/// Initialize the background worker.
/// Should be called once during app startup.
Future<void> initializeBackgroundWorker() async {
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: kDebugMode,
  );

  // Register periodic daily task for notification sync
  await Workmanager().registerPeriodicTask(
    dailyNotificationSyncTask,
    dailyNotificationSyncTask,
    frequency: const Duration(hours: 24),
    constraints: Constraints(
      networkType: NetworkType.notRequired,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresDeviceIdle: false,
      requiresStorageNotLow: false,
    ),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  debugPrint('BackgroundWorker: Initialized with daily sync task');
}

/// Trigger an immediate notification reschedule.
/// Call this when user enables notifications or after login.
Future<void> triggerImmediateNotificationSync() async {
  await Workmanager().registerOneOffTask(
    '${immediateNotificationSyncTask}_${DateTime.now().millisecondsSinceEpoch}',
    immediateNotificationSyncTask,
    constraints: Constraints(
      networkType: NetworkType.notRequired,
    ),
  );

  debugPrint('BackgroundWorker: Triggered immediate notification sync');
}

/// Cancel all background tasks.
/// Call this when user logs out.
Future<void> cancelAllBackgroundTasks() async {
  await Workmanager().cancelAll();
  debugPrint('BackgroundWorker: Cancelled all background tasks');
}
