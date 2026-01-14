# Fix Implementation Guide: Mocking Layer Enhancements

## Issue Summary
**Affected Areas**: Test files with external dependencies (network, database, device features)  
**Current Status**: Multiple tests depend on real implementations, causing reliability issues  
**Priority**: Medium (Address in Backlog)  
**Estimated Effort**: 1-2 weeks

## Problem Description
Several test categories may benefit from improved mocking to reduce dependency on real implementations and improve test reliability. Tests that depend on external factors like network connectivity, database state, or device features are more likely to fail intermittently and are harder to debug.

Current issues include:
- Tests depend on real network calls
- Tests require actual database state
- Tests need device-specific features
- Tests share state between runs
- Tests are slow due to real implementation overhead

## Impact Analysis

### Test Categories That Need Better Mocking

1. **Certificate Tests** (13% failure rate)
   - Depend on real certificate validation
   - Need specific certificate configurations
   - Network security settings affect results

2. **Sync Tests** (0% failure rate, but could be improved)
   - Real sync operations with servers
   - Network dependency issues
   - Account authentication requirements

3. **Notification Tests** (8% failure rate)
   - Depend on Android notification system
   - Need device-specific behavior
   - Permission handling variations

4. **Performance Tests** (33% failure rate)
   - Real database operations
   - Network timing variations
   - Device performance differences

## Implementation Tasks

### Task 1: Identify Mocking Opportunities
**Priority**: P0 - Critical  
**Acceptance Criteria**: All test dependencies identified and cataloged

**Steps**:
1. **Catalog external dependencies**
   ```dart
   // lib/testing/dependency_catalog.dart
   class DependencyCatalog {
     static final List<ExternalDependency> dependencies = [
       ExternalDependency(
         name: 'Network Service',
         category: DependencyCategory.network,
         usedIn: ['certificate_integration_test.dart', 'sync_integration_test.dart'],
         currentImplementation: 'RealNetworkService',
         recommendedMock: 'MockNetworkService',
       ),
       ExternalDependency(
         name: 'Database Provider',
         category: DependencyCategory.database,
         usedIn: ['event_crud_integration_test.dart', 'performance_integration_test.dart'],
         currentImplementation: 'EventDatabase',
         recommendedMock: 'MockEventDatabase',
       ),
       ExternalDependency(
         name: 'Certificate Validator',
         category: DependencyCategory.security,
         usedIn: ['certificate_integration_test.dart'],
         currentImplementation: 'CertificateValidatorImpl',
         recommendedMock: 'MockCertificateValidator',
       ),
       ExternalDependency(
         name: 'Notification Service',
         category: DependencyCategory.device,
         usedIn: ['notification_integration_test.dart', 'android_notification_delivery_integration_test.dart'],
         currentImplementation: 'AndroidNotificationService',
         recommendedMock: 'MockNotificationService',
       ),
       ExternalDependency(
         name: 'Sync Service',
         category: DependencyCategory.network,
         usedIn: ['sync_integration_test.dart', 'sync_settings_integration_test.dart'],
         currentImplementation: 'SyncServiceImpl',
         recommendedMock: 'MockSyncService',
       ),
       ExternalDependency(
         name: 'Calendar Provider',
         category: DependencyCategory.device,
         usedIn: ['calendar_integration_test.dart', 'conflict_resolution_integration_test.dart'],
         currentImplementation: 'CalendarProviderImpl',
         recommendedMock: 'MockCalendarProvider',
       ),
     ];
     
     static List<ExternalDependency> getByCategory(DependencyCategory category) {
       return dependencies.where((d) => d.category == category).toList();
     }
     
     static List<ExternalDependency> getByTestFile(String testFile) {
       return dependencies.where((d) => d.usedIn.contains(testFile)).toList();
     }
   }
   ```

2. **Analyze dependency impact**
   ```dart
   // lib/testing/dependency_analyzer.dart
   class DependencyAnalyzer {
     static Map<String, double> calculateDependencyImpact() {
       return {
         'Network Service': _calculateNetworkImpact(),
         'Database Provider': _calculateDatabaseImpact(),
         'Certificate Validator': _calculateCertificateImpact(),
         'Notification Service': _calculateNotificationImpact(),
         'Sync Service': _calculateSyncImpact(),
         'Calendar Provider': _calculateCalendarImpact(),
       };
     }
     
     static double _calculateNetworkImpact() {
       // Calculate impact based on:
       // - Number of tests using network
       // - Average test duration with network calls
       // - Failure rate of network-dependent tests
       return 0.75; // High impact
     }
     
     static double _calculateDatabaseImpact() {
       return 0.85; // Very high impact
     }
     
     // Similar calculations for other dependencies
   }
   ```

3. **Prioritize mocking candidates**
   ```dart
   // lib/testing/priority_list.dart
   class MockingPriorityList {
     static List<MockingCandidate> getPrioritizedList() {
       final dependencies = DependencyCatalog.dependencies;
       final impactScores = DependencyAnalyzer.calculateDependencyImpact();
       
       final candidates = dependencies.map((dep) {
         return MockingCandidate(
           dependency: dep,
           impactScore: impactScores[dep.name] ?? 0.5,
           easeOfMocking: _estimateMockingEase(dep),
           currentFailureRate: _getCurrentFailureRate(dep),
         );
       }).toList();
       
       // Sort by priority (impact * failure rate / ease)
       candidates.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
       
       return candidates;
     }
     
     static double _estimateMockingEase(ExternalDependency dep) {
       // Estimate how easy it is to create mocks
       // based on interface complexity and usage patterns
       return 0.8; // Example score
     }
     
     static double _getCurrentFailureRate(ExternalDependency dep) {
       // Get failure rate from tests using this dependency
       return 0.10; // 10% average failure rate
     }
   }
   ```

4. **Create dependency documentation**
   ```dart
   /// External Dependency Documentation
   /// 
   /// Each external dependency should have documentation including:
   /// - Purpose and responsibilities
   /// - Current implementation details
   /// - Mock implementation requirements
   /// - Test usage examples
   /// - Known limitations and issues
   ```

### Task 2: Implement Comprehensive Mocks
**Priority**: P0 - Critical  
**Acceptance Criteria**: Complete mock implementations for top-priority dependencies

**Steps**:
1. **Create mock network service**
   ```dart
   // lib/testing/mocks/mock_network_service.dart
   import 'package:mockito/mockito.dart';
   
   class MockNetworkService extends Mock implements NetworkService {
     final _responses = <String, HttpResponse>{};
     final _delays = <String, Duration>{};
     final _callCount = <String, int>{};
     
     void setResponse(String url, HttpResponse response) {
       _responses[url] = response;
     }
     
     void setDelay(String url, Duration delay) {
       _delays[url] = delay;
     }
     
     void resetCallCount(String url) {
       _callCount[url] = 0;
     }
     
     @override
     Future<HttpResponse> get(String url) async {
       final delay = _delays[url] ?? Duration.zero;
       if (delay > Duration.zero) {
         await Future.delayed(delay);
       }
       
       _callCount[url] = (_callCount[url] ?? 0) + 1;
       
       final response = _responses[url];
       if (response != null) {
         return response;
       }
       
       // Default mock response
       return HttpResponse(statusCode: 200, body: '{}');
     }
     
     int getCallCount(String url) => _callCount[url] ?? 0;
   }
   
   // Usage example
   void setupNetworkMock() {
     final mockNetwork = MockNetworkService();
     
     mockNetwork.setResponse(
       'https://api.example.com/events',
       HttpResponse(
         statusCode: 200,
         body: jsonEncode({'events': []}),
       ),
     );
     
     mockNetwork.setDelay('https://api.example.com/events', Duration(milliseconds: 100));
     
     // Register mock with DI container
     Get.replace<NetworkService>(mockNetwork);
   }
   ```

2. **Create mock database**
   ```dart
   // lib/testing/mocks/mock_event_database.dart
   import 'package:mockito/mockito.dart';
   
   class MockEventDatabase extends Mock implements EventDatabase {
     final _events = <String, Event>{};
     final _callLog = <String, List<dynamic>>{};
     
     void setEvent(Event event) {
       _events[event.id] = event;
     }
     
     void setEvents(List<Event> events) {
       for (final event in events) {
         _events[event.id] = event;
       }
     }
     
     void clearEvents() {
       _events.clear();
     }
     
     @override
     Future<Event> insertEvent(Event event) async {
       _callLog['insertEvent']?.add(event);
       _events[event.id] = event;
       return event;
     }
     
     @override
     Future<Event?> getEvent(String id) async {
       _callLog['getEvent']?.add(id);
       return _events[id];
     }
     
     @override
     Future<List<Event>> getAllEvents() async {
       _callLog['getAllEvents']?.add(DateTime.now());
       return _events.values.toList();
     }
     
     @override
     Future<void> updateEvent(String id, Event event) async {
       _callLog['updateEvent']?.add([id, event]);
       _events[id] = event;
     }
     
     @override
     Future<void> deleteEvent(String id) async {
       _callLog['deleteEvent']?.add(id);
       _events.remove(id);
     }
     
     List<dynamic> getCallLog(String method) => _callLog[method] ?? [];
   }
   
   // Usage example
   void setupDatabaseMock() {
     final mockDatabase = MockEventDatabase();
     
     // Pre-populate with test data
     mockDatabase.setEvents([
       EventTestFactory.createValidEvent(id: 'event_1'),
       EventTestFactory.createValidEvent(id: 'event_2'),
     ]);
     
     // Register mock with DI container
     Get.replace<EventDatabase>(mockDatabase);
   }
   ```

3. **Create mock certificate validator**
   ```dart
   // lib/testing/mocks/mock_certificate_validator.dart
   import 'package:mockito/mockito.dart';
   
   class MockCertificateValidator extends Mock implements CertificateValidator {
     final _validationResults = <String, bool>{};
     final _validationLog = <List<dynamic>, dynamic>{};
     
     void setValidationResult(String certificateId, bool isValid) {
       _validationResults[certificateId] = isValid;
     }
     
     void setValidationError(String certificateId, Exception error) {
       _validationLog[{certificateId, 'error'}] = error;
     }
     
     @override
     Future<bool> validate(X509Certificate certificate) async {
       final certificateId = certificate.subject;
       final error = _validationLog[{certificateId, 'error'}];
       
       if (error != null) {
         throw error;
       }
       
       return _validationResults[certificateId] ?? true;
     }
     
     @override
     Future<bool> validateChain(List<X509Certificate> chain) async {
       for (final cert in chain) {
         if (!(await validate(cert))) {
           return false;
         }
       }
       return true;
     }
   }
   ```

4. **Create mock notification service**
   ```dart
   // lib/testing/mocks/mock_notification_service.dart
   import 'package:mockito/mockito.dart';
   
   class MockNotificationService extends Mock implements NotificationService {
     final _notifications = <String, AppNotification>{};
     final _actionLog = <String, List<NotificationAction>>{};
     
     void setNotification(AppNotification notification) {
       _notifications[notification.id] = notification;
     }
     
     void clearNotifications() {
       _notifications.clear();
       _actionLog.clear();
     }
     
     @override
     Future<String> showNotification(AppNotification notification) async {
       _notifications[notification.id] = notification;
       return notification.id;
     }
     
     @override
     Future<void> cancelNotification(String id) async {
       _notifications.remove(id);
     }
     
     @override
     Future<void> handleNotificationAction(String notificationId, String action) async {
       _actionLog.putIfAbsent(notificationId, () => [])
         .add(NotificationAction(notificationId, action));
     }
     
     List<NotificationAction> getActionsForNotification(String notificationId) {
       return _actionLog[notificationId] ?? [];
     }
   }
   ```

5. **Create mock sync service**
   ```dart
   // lib/testing/mocks/mock_sync_service.dart
   import 'package:mockito/mockito.dart';
   
   class MockSyncService extends Mock implements SyncService {
     final _syncStates = <String, SyncState>{};
     final _syncLog = <String, List<SyncResult>>{};
     
     void setSyncState(String accountId, SyncState state) {
       _syncStates[accountId] = state;
     }
     
     void addSyncResult(String accountId, SyncResult result) {
       _syncLog.putIfAbsent(accountId, () => []).add(result);
     }
     
     void resetSyncLog(String accountId) {
       _syncLog[accountId] = [];
     }
     
     @override
     Future<SyncResult> syncAccount(String accountId) async {
       final result = SyncResult(
         success: true,
         syncedItems: 10,
         errors: [],
       );
       
       addSyncResult(accountId, result);
       return result;
     }
     
     @override
     Stream<SyncState> getSyncState(String accountId) {
       return Stream.value(_syncStates[accountId] ?? SyncState.idle);
     }
     
     List<SyncResult> getSyncLog(String accountId) {
       return _syncLog[accountId] ?? [];
     }
   }
   ```

### Task 3: Reduce Test Reliance on Real Device Features
**Priority**: P1 - High  
**Acceptance Criteria**: Tests can run reliably without device-specific features

**Steps**:
1. **Create device abstraction layer**
   ```dart
   // lib/testing/device_abstraction.dart
   abstract class DeviceAbstraction {
     factory DeviceAbstraction.test() => TestDeviceAbstraction();
     factory DeviceAbstraction.real() => RealDeviceAbstraction();
     
     Future<bool> hasNetworkConnection();
     Future<bool> hasStoragePermission();
     Future<int> getFreeStorageSpace();
     Future<DateTime> getCurrentTime();
     String getDeviceId();
   }
   
   class TestDeviceAbstraction implements DeviceAbstraction {
     bool _networkAvailable = true;
     bool _storagePermission = true;
     int _freeSpace = 1024 * 1024 * 100; // 100MB
     
     @override
     Future<bool> hasNetworkConnection() async => _networkAvailable;
     
     @override
     Future<bool> hasStoragePermission() async => _storagePermission;
     
     @override
     Future<int> getFreeStorageSpace() async => _freeSpace;
     
     @override
     Future<DateTime> getCurrentTime() async => DateTime.now();
     
     @override
     String getDeviceId() => 'test_device_123';
     
     // Test configuration methods
     void setNetworkAvailable(bool available) => _networkAvailable = available;
     void setStoragePermission(bool permission) => _storagePermission = permission;
     void setFreeSpace(int spaceMB) => _freeSpace = spaceMB * 1024 * 1024;
   }
   ```

2. **Create mock calendar provider**
   ```dart
   // lib/testing/mocks/mock_calendar_provider.dart
   import 'package:mockito/mockito.dart';
   
   class MockCalendarProvider extends Mock implements CalendarProvider {
     final _calendars = <String, Calendar>{};
     final _events = <String, List<CalendarEvent>>{};
     
     void setCalendar(Calendar calendar) {
       _calendars[calendar.id] = calendar;
     }
     
     void setEvents(String calendarId, List<CalendarEvent> events) {
       _events[calendarId] = events;
     }
     
     void clearAll() {
       _calendars.clear();
       _events.clear();
     }
     
     @override
     Future<List<Calendar>> getCalendars() async {
       return _calendars.values.toList();
     }
     
     @override
     Future<CalendarEvent?> getEvent(String calendarId, String eventId) async {
       final events = _events[calendarId] ?? [];
       return events.firstWhere((e) => e.id == eventId, orElse: () => null);
     }
     
     @override
     Future<List<CalendarEvent>> getEvents(
       String calendarId,
       DateTime start,
       DateTime end,
     ) async {
       final events = _events[calendarId] ?? [];
       return events
           .where((e) => e.start.isAfter(start) && e.start.isBefore(end))
           .toList();
     }
   }
   ```

3. **Implement test-specific feature flags**
   ```dart
   // lib/testing/test_flags.dart
   class TestFlags {
     static bool _useMocks = false;
     static bool _enableNetworkMocking = true;
     static bool _enableDatabaseMocking = true;
     static bool _skipSlowOperations = false;
     
     static void enableMocks() => _useMocks = true;
     static void disableMocks() => _useMocks = false;
     
     static bool get useMocks => _useMocks;
     static bool get enableNetworkMocking => _enableNetworkMocking;
     static bool get enableDatabaseMocking => _enableDatabaseMocking;
     static bool get skipSlowOperations => _skipSlowOperations;
     
     static void configure({
       bool useMocks = true,
       bool enableNetworkMocking = true,
       bool enableDatabaseMocking = true,
       bool skipSlowOperations = false,
     }) {
       _useMocks = useMocks;
       _enableNetworkMocking = enableNetworkMocking;
       _enableDatabaseMocking = enableDatabaseMocking;
       _skipSlowOperations = skipSlowOperations;
     }
   }
   
   // Usage in production code
   class NetworkService {
     NetworkService({NetworkService? mock}) {
       if (TestFlags.useMocks && mock != null) {
         _delegate = mock;
       } else {
         _delegate = RealNetworkService();
       }
     }
   }
   ```

4. **Create test utilities for feature management**
   ```dart
   // lib/testing/test_utilities.dart
   class TestUtilities {
     static final List<VoidCallback> _cleanupCallbacks = [];
     
     static void setupMocks() {
       TestFlags.enableMocks();
       
       // Set up all mocks
       setupNetworkMock();
       setupDatabaseMock();
       setupCertificateMock();
       setupNotificationMock();
       setupSyncMock();
       
       _cleanupCallbacks.add(() {
         TestFlags.disableMocks();
       });
     }
     
     static void cleanup() {
       for (final callback in _cleanupCallbacks) {
         callback();
       }
       _cleanupCallbacks.clear();
     }
     
     static Future<T> runWithMocks<T>(Future<T> Function() test) async {
       try {
         setupMocks();
         return await test();
       } finally {
         cleanup();
       }
     }
   }
   ```

### Task 4: Improve Test Isolation Through Better Mocking
**Priority**: P1 - High  
**Acceptance Criteria**: Tests are fully isolated and can run independently

**Steps**:
1. **Create test context manager**
   ```dart
   // lib/testing/test_context_manager.dart
   class TestContextManager {
     final _contexts = <String, TestContext>{};
     final _defaultContext = TestContext();
     
     TestContext getContext(String testId) {
       return _contexts[testId] ?? _defaultContext;
     }
     
     void createContext(String testId) {
       _contexts[testId] = TestContext();
     }
     
     void destroyContext(String testId) {
       _contexts[testId]?.dispose();
       _contexts.remove(testId);
     }
     
     void destroyAllContexts() {
       for (final context in _contexts.values) {
         context.dispose();
       }
       _contexts.clear();
     }
   }
   
   class TestContext {
     final MockNetworkService network;
     final MockEventDatabase database;
     final MockCalendarProvider calendar;
     final MockNotificationService notifications;
     final MockSyncService sync;
     
     TestContext()
       : network = MockNetworkService(),
         database = MockEventDatabase(),
         calendar = MockCalendarProvider(),
         notifications = MockNotificationService(),
         sync = MockSyncService() {
       // Register mocks in DI container
       Get.put<NetworkService>(network);
       Get.put<EventDatabase>(database);
       Get.put<CalendarProvider>(calendar);
       Get.put<NotificationService>(notifications);
       Get.put<SyncService>(sync);
     }
     
     void dispose() {
       // Clean up all mocks
       network.clearOutputs();
       database.clearEvents();
       calendar.clearAll();
       notifications.clearNotifications();
       sync.resetSyncLog('default');
     }
   }
   ```

2. **Implement test isolation patterns**
   ```dart
   // In test files
   void main() {
     TestContextManager? contextManager;
     
     setUpAll(() {
       contextManager = TestContextManager();
     });
     
     setUp(() {
       final testId = DateTime.now().millisecondsSinceEpoch.toString();
       contextManager!.createContext(testId);
     });
     
     tearDown(() {
       final currentContext = contextManager!.getContext('current');
       currentContext.dispose();
     });
     
     testWidgets('Isolated test', (tester) async {
       final context = contextManager!.getContext('current');
       
       // Use context-specific mocks
       context.database.setEvent(testEvent);
       
       // Test execution
     });
   }
   ```

3. **Add test data factory integration**
   ```dart
   // lib/testing/test_data_factory.dart
   class TestDataFactory {
     final TestContext _context;
     
     TestDataFactory(this._context);
     
     Event createEvent({
       String? id,
       String? title,
       DateTime? start,
       DateTime? end,
     }) {
       final event = Event(
         id: id ?? 'test_event_${DateTime.now().millisecondsSinceEpoch}',
         title: title ?? 'Test Event',
         start: start ?? DateTime.now().add(Duration(hours: 1)),
         end: end ?? DateTime.now().add(Duration(hours: 2)),
       );
       
       // Add to mock database
       _context.database.setEvent(event);
       
       return event;
     }
     
     Calendar createCalendar({
       String? id,
       String? name,
     }) {
       final calendar = Calendar(
         id: id ?? 'test_calendar_${DateTime.now().millisecondsSinceEpoch}',
         name: name ?? 'Test Calendar',
       );
       
       // Add to mock calendar provider
       _context.calendar.setCalendar(calendar);
       
       return calendar;
     }
     
     void clearAll() {
       _context.database.clearEvents();
       _context.calendar.clearAll();
     }
   }
   ```

4. **Create test isolation validation**
   ```dart
   // lib/testing/isolation_validator.dart
   class IsolationValidator {
     static bool validateTestIsolation(String testId) {
       final context = TestContextManager().getContext(testId);
       
       // Check for state leaks
       final networkCallsBefore = context.network.getCallCount('test');
       final databaseStateBefore = context.database.getAllEvents();
       
       // Run test operations
       // ...
       
       // Check for state changes
       final networkCallsAfter = context.network.getCallCount('test');
       final databaseStateAfter = context.database.getAllEvents();
       
       // Validate isolation
       return networkCallsBefore == networkCallsAfter &&
              databaseStateBefore.length == databaseStateAfter.length;
     }
     
     static List<String> getIsolationIssues(String testId) {
       final issues = <String>[];
       final context = TestContextManager().getContext(testId);
       
       // Check each mock for potential isolation issues
       if (context.network.getCallCount('previous_test') > 0) {
         issues.add('Network calls from previous test detected');
       }
       
       if (context.database.getAllEvents().isNotEmpty) {
         issues.add('Database contains data from previous tests');
       }
       
       return issues;
     }
   }
   ```

## Success Criteria
- [ ] All external dependencies identified and cataloged
- [ ] Complete mock implementations for top-priority dependencies
- [ ] Tests can run reliably without real device features
- [ ] Test isolation validated and improved
- [ ] Test execution time reduced by 50% or more

## Testing Validation
After implementing fixes, run the following validation:
```bash
# Run tests with mocks
flutter test integration_test/ --verbose

# Check mock coverage
dart lib/testing/mock_coverage_report.dart

# Validate test isolation
dart lib/testing/isolation_validator.dart
```

Expected result: Significant improvement in test reliability and reduction in execution time

## Mock Categories

### Network Mocks
- HTTP request/response handling
- WebSocket simulation
- Authentication flow
- Error simulation

### Database Mocks
- CRUD operations
- Transaction handling
- Query execution
- Connection pooling

### Device Feature Mocks
- Notification service
- Calendar provider
- File system access
- Device information

### Service Mocks
- Sync service
- Authentication service
- Settings service
- Analytics service

## Technical Notes
- Start with highest-impact dependencies first
- Use dependency injection for easy mocking
- Ensure mocks match real implementation interfaces
- Add mock verification for test assertions

## Risk Assessment
**Risk Level**: Medium  
**Mitigation**: Implement mocks incrementally; validate against real implementations; use mocks only for testing

## Related Files and Dependencies
- **Mock implementations**: `lib/testing/mocks/` directory
- **Dependency catalog**: `lib/testing/dependency_catalog.dart`
- **Test utilities**: `lib/testing/test_utilities.dart`
- **DI container**: Check `lib/` for dependency injection setup

## Benefits Expected
1. **Improved Test Reliability**: Tests don't fail due to external factors
2. **Faster Test Execution**: No real I/O or network overhead
3. **Better Test Isolation**: No state sharing between tests
4. **Easier Debugging**: Deterministic behavior with mock responses
5. **Parallel Execution**: Tests can run in parallel without conflicts
