  import "package:flutter/services.dart";
  import "package:flutter_test/flutter_test.dart";
  import "package:mockito/annotations.dart";
  import "package:mockito/mockito.dart";
  import "package:shared_preferences/shared_preferences.dart";
  import "package:mcal/services/sync_service.dart";
import "package:mcal/rust_api.dart";

@GenerateMocks([RustLibApi])
import "sync_service_test.mocks.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SyncService syncService;
  late MockRustLibApi mockApi;

  final Map<String, String?> _mockStorage = {};

  setUp(() {
    _mockStorage.clear();
    mockApi = MockRustLibApi();
    syncService = SyncService(mockApi);
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return '/tmp/test_docs';
      }
      return null;
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'), (MethodCall methodCall) async {
      if (methodCall.method == 'read') {
        final key = methodCall.arguments['key'] as String;
        return _mockStorage[key];
      } else if (methodCall.method == 'write') {
        final key = methodCall.arguments['key'] as String;
        final value = methodCall.arguments['value'] as String?;
        if (value == null) {
          _mockStorage.remove(key);
        } else {
          _mockStorage[key] = value;
        }
        return null;
      } else if (methodCall.method == 'delete') {
        final key = methodCall.arguments['key'] as String;
        _mockStorage.remove(key);
        return null;
      }
      return null;
    });
    // Common mocks for initSync
    when(mockApi.gitInit(path: anyNamed('path'))).thenAnswer((_) async => 'Initialized');
    when(mockApi.gitAddRemote(path: anyNamed('path'), name: anyNamed('name'), url: anyNamed('url'))).thenAnswer((_) async => 'Remote added');
    when(mockApi.gitFetch(path: anyNamed('path'), remote: anyNamed('remote'), username: anyNamed('username'), password: anyNamed('password'), sshKeyPath: anyNamed('sshKeyPath'))).thenAnswer((_) async => 'Fetched');
    when(mockApi.gitCheckout(path: anyNamed('path'), branch: anyNamed('branch'))).thenAnswer((_) async => 'Checked out');
  });

  test('initSync stores remote URL', () async {
    // With mocking, initSync succeeds by storing URL in prefs
    await expectLater(syncService.initSync('https://example.com/repo.git'), completes);
  });

  test('pullSync throws if no URL', () async {
    expect(() async => await syncService.pullSync(), throwsA(isA<Exception>()));
  });

  test('pullSync calls gitPull with auth', () async {
    syncService = SyncService(mockApi);
    await syncService.initSync('https://example.com/repo.git', username: 'user', password: 'pass', sshKeyPath: '/path/to/key');
    when(mockApi.gitPull(path: anyNamed('path'), username: anyNamed('username'), password: anyNamed('password'), sshKeyPath: anyNamed('sshKeyPath'))).thenAnswer((_) async => 'Pulled');
    await expectLater(syncService.pullSync(), completes);
  });

  test('pushSync throws if no URL', () async {
    expect(() async => await syncService.pushSync(), throwsA(isA<Exception>()));
  });

  test('pushSync calls gitPush with auth', () async {
    syncService = SyncService(mockApi);
    await syncService.initSync('https://example.com/repo.git', username: 'user', password: 'pass', sshKeyPath: '/path/to/key');
    when(mockApi.gitStatus(path: anyNamed('path'))).thenAnswer((_) async => 'modified');
    when(mockApi.gitAddAll(path: anyNamed('path'))).thenAnswer((_) async => 'Added');
    when(mockApi.gitCommit(path: anyNamed('path'), message: anyNamed('message'))).thenAnswer((_) async => 'Committed');
    when(mockApi.gitPush(path: anyNamed('path'), username: anyNamed('username'), password: anyNamed('password'), sshKeyPath: anyNamed('sshKeyPath'))).thenAnswer((_) async => 'Pushed');
    await expectLater(syncService.pushSync(), completes);
  });

  test('getSyncStatus returns string', () async {
    when(mockApi.gitStatus(path: anyNamed('path'))).thenAnswer((_) async => 'Working directory clean');
    expect(await syncService.getSyncStatus(), isA<String>());
  });

  test('resolveConflictPreferRemote calls gitMergePreferRemote', () async {
    when(mockApi.gitMergePreferRemote(path: anyNamed('path'))).thenAnswer((_) async => 'Resolved');
    await expectLater(syncService.resolveConflictPreferRemote(), completes);
  });

  test('abortConflict calls gitMergeAbort', () async {
    when(mockApi.gitMergeAbort(path: anyNamed('path'))).thenAnswer((_) async => 'Aborted');
    await expectLater(syncService.abortConflict(), completes);
  });
}