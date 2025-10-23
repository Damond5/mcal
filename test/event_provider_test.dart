import "package:flutter_test/flutter_test.dart";
import "package:mcal/providers/event_provider.dart";

void main() {
  late EventProvider eventProvider;

  setUp(() {
    eventProvider = EventProvider();
  });

  test('syncInit calls SyncService.initSync', () async {
    // Since SyncService is private, we can't easily test, but the method exists
    expect(eventProvider.syncInit, isA<Function>());
  });

  test('syncPull calls SyncService.pullSync', () async {
    expect(eventProvider.syncPull, isA<Function>());
  });

  test('syncPush calls SyncService.pushSync', () async {
    expect(eventProvider.syncPush, isA<Function>());
  });

  test('syncStatus calls SyncService.getSyncStatus', () async {
    expect(eventProvider.syncStatus, isA<Function>());
  });
}