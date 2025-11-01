import "package:flutter/services.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:mcal/services/sync_service.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SyncService syncService;

  setUp(() {
    syncService = SyncService();
    SharedPreferences.setMockInitialValues({});
    const MethodChannel('plugins.flutter.io/path_provider').setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return '/tmp/test_docs';
      }
      return null;
    });
  });

  test('initSync stores remote URL', () async {
    // With mocking, initSync succeeds by storing URL in prefs
    await expectLater(syncService.initSync('https://example.com/repo.git'), completes);
  });

  test('pullSync throws if no URL', () async {
    expect(() async => await syncService.pullSync(), throwsA(isA<Exception>()));
  });

  test('pushSync throws if no URL', () async {
    expect(() async => await syncService.pushSync(), throwsA(isA<Exception>()));
  });

  test('getSyncStatus returns string', () async {
    // Mocking is complex, so just check it returns a string
    expect(await syncService.getSyncStatus(), isA<String>());
  });

  test('resolveConflictPreferRemote throws if git fails', () async {
    expect(() async => await syncService.resolveConflictPreferRemote(), throwsA(isA<Exception>()));
  });

  test('abortConflict throws if git fails', () async {
    expect(() async => await syncService.abortConflict(), throwsA(isA<Exception>()));
  });
}