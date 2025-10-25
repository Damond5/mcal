import 'package:flutter_test/flutter_test.dart';
import 'package:mcal/models/sync_settings.dart';

void main() {
  group('SyncSettings', () {
    test('default constructor', () {
      final settings = SyncSettings();
      expect(settings.autoSyncEnabled, true);
      expect(settings.syncFrequencyMinutes, 15);
      expect(settings.resumeSyncEnabled, true);
    });

    test('copyWith', () {
      final settings = SyncSettings();
      final newSettings = settings.copyWith(autoSyncEnabled: false, syncFrequencyMinutes: 30);
      expect(newSettings.autoSyncEnabled, false);
      expect(newSettings.syncFrequencyMinutes, 30);
      expect(newSettings.resumeSyncEnabled, true);
    });

    test('toJson and fromJson', () {
      final settings = SyncSettings(autoSyncEnabled: false, syncFrequencyMinutes: 20, resumeSyncEnabled: false);
      final json = settings.toJson();
      final fromJson = SyncSettings.fromJson(json);
      expect(fromJson.autoSyncEnabled, false);
      expect(fromJson.syncFrequencyMinutes, 20);
      expect(fromJson.resumeSyncEnabled, false);
    });
  });
}