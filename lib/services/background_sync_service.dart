import '../providers/event_provider.dart';

class BackgroundSyncService {
  static Future<bool> executePeriodicSync() async {
    try {
      final provider = EventProvider();
      await provider.loadSyncSettings();
      await provider.autoSyncPeriodic();
      return true;
    } catch (e) {
      // Log error, but return true to not retry immediately
      return true;
    }
  }
}
