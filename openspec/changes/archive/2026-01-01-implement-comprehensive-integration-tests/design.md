# Design: Implement Comprehensive Integration Tests

## Architectural Decisions

### Test Organization Strategy

**Decision**: Organize integration tests into logical files by feature area rather than keeping all tests in a single file.

**Rationale**:
- Single file approach (`app_integration_test.dart`) becomes unwieldy as tests grow (current 362 lines)
- Feature-based organization aligns with existing code structure (models, providers, services, widgets)
- Makes tests easier to find and maintain
- Allows selective test execution during development
- Follows Flutter best practices for larger projects

**Implementation**:
```
integration_test/
├── helpers/
│   └── test_fixtures.dart          # Common test fixtures and data
├── event_crud_integration_test.dart  # Event creation, editing, deletion
├── calendar_integration_test.dart     # Calendar navigation and interactions
├── event_form_integration_test.dart  # Event form dialog and validation
├── event_list_integration_test.dart  # Event list display and interactions
├── sync_integration_test.dart        # Git sync workflows
├── conflict_resolution_integration_test.dart  # Sync conflict scenarios
├── sync_settings_integration_test.dart        # Sync settings dialog
├── notification_integration_test.dart        # Notification scheduling/display
├── certificate_integration_test.dart     # SSL certificate handling
├── lifecycle_integration_test.dart           # App lifecycle and persistence
├── edge_cases_integration_test.dart          # Error handling and edge cases
├── performance_integration_test.dart        # Performance and load tests
├── accessibility_integration_test.dart      # Accessibility testing
├── gesture_integration_test.dart          # Gesture testing (long-press, drag)
└── responsive_layout_integration_test.dart # Responsive layout testing
```

### Test Fixture Pattern

**Decision**: Create reusable test fixtures for common scenarios.

**Rationale**:
- Reduces code duplication across tests
- Ensures consistency in test data
- Makes tests more readable and maintainable
- Allows quick setup for complex scenarios

**Implementation**:
```dart
// integration_test/helpers/test_fixtures.dart
class TestFixtures {
  static Event createSampleEvent({DateTime? date, String? title});
  static Event createRecurringEvent({String recurrence = 'weekly'});
  static Event createAllDayEvent({DateTime? date});
  static Event createMultiDayEvent({DateTime? startDate, DateTime? endDate});
  static List<Event> createLargeEventSet({int count = 100});

  // Helper methods for mock setup
  static Future<void> setupMockGitRepository();
  static Future<void> setupMockNotifications();
  static Future<void> setupMockCertificateService();

  // Specific fixtures for common patterns
  static Event createWeeklyMeeting();
  static Event createBirthdayEvent();
  static Event createVacationEvent();
}

// Usage in tests
testWidgets('Adding event displays on calendar', (tester) async {
  final event = TestFixtures.createSampleEvent();
  // Test implementation
});
```

**Fixture Design Guidelines**:

1. **Clear, Single Purposes**: Each fixture method should have one clear purpose
   - Good: `createWeeklyMeeting()` creates a weekly meeting event
   - Avoid: `createEvent({recurrence: 'weekly', isAllDay: false, ...})` with many optional parameters

2. **Prefer Specific Fixtures**: Create multiple specific fixtures over one over-parameterized fixture
   - Good: `createWeeklyMeeting()`, `createBirthdayEvent()`, `createVacationEvent()`
   - Avoid: `createEvent({recurrence, isAllDay, hasDescription, ...})` with all parameters

3. **Document Fixtures Clearly**: Add comments explaining what each fixture creates and why
   ```dart
   // Creates a typical weekly team meeting event
   // Used for testing recurring event functionality
   static Event createWeeklyMeeting() {
     return Event(
       title: 'Team Meeting',
       startDate: DateTime.now(),
       startTime: '14:00',
       endTime: '15:00',
       recurrence: 'weekly',
       description: 'Weekly sync with team',
     );
   }
   ```

### Test Selector Guidelines

**Decision**: Use stable selectors in priority order to reduce test fragility.

**Rationale**:
- UI refactors break tests that use implementation-specific selectors
- Semantic selectors are more stable and user-focused
- Reduces maintenance burden when UI changes

**Implementation**:
```dart
// Preferred selector order (most stable to least stable):

// 1. Semantic labels (MOST STABLE)
find.bySemanticsLabel('Save button')
find.bySemanticsLabel('Add event button')

// 2. Widget keys (STABLE)
find.byKey(Key('save-button'))
find.byKey(Key('event-title-field'))

// 3. Widget types (LESS STABLE)
find.byType(FloatingActionButton)
find.byType(ElevatedButton)

// 4. Text content (LEAST STABLE)
find.text('Save')
find.text('Add Event')
```

**Best Practices**:
- Use semantic labels for buttons and interactive elements
- Use widget keys for components that need reliable selection
- Use widget types only when semantic labels and keys aren't available
- Avoid text content selectors when text is likely to change
- Test UI elements, not implementation details

### Mocking Strategy

**Decision**: Continue using existing mock patterns from unit tests for external dependencies.

**Rationale**:
- Integration tests should test app behavior, not external services
- Mocking makes tests deterministic and fast
- Existing mock infrastructure in test_helpers.dart is proven
- Avoids need for real Git repositories, file system, or notification services

**Implementation**:
- Git operations: Mock RustLibApi methods
- File system: Mock path_provider
- Notifications: Mock flutter_local_notifications channel
- Network: Mock all HTTP/SSH operations
- Workmanager: Mock background sync tasks
- Certificates: Mock certificate service for SSL operations

**New Mock Functions to Create**:
- `setupMockGitRepository()`: Mock Git operations for sync workflows
- `setupMockNotifications()`: Mock notification channel for notification tests
- `setupMockCertificateService()`: Mock SSL certificate loading for sync tests

**Trade-offs**:
- Pro: Fast, reliable, no external dependencies
- Con: Doesn't catch integration issues with real services
- Mitigation: Manual testing with real services still valuable

### Test Isolation Strategy

**Decision**: Use test-specific directories and cleanup for isolation.

**Rationale**:
- Tests must not interfere with each other
- Tests must not leave artifacts on filesystem
- Existing test_helpers.dart infrastructure supports this
- Platform-independent approach needed for cross-platform testing

**Implementation**:
```dart
// Each test file
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTestEnvironment();
    await setupTestFixtures();
  });

  setUp(() async {
    await cleanTestEvents();
  });

  tearDownAll(() async {
    await cleanupTestEnvironment();
  });
}
```

**Continued use of MCAL_TEST_CLEANUP environment variable** for debugging.

### Test Data Management

**Decision**: Use test fixtures and helpers for test data, not hardcoded values.

**Rationale**:
- Makes tests more readable
- Easier to update test data
- Reduces errors from typos
- Consistent data across tests

**Implementation**:
- Centralized fixture definitions
- Parameterized fixtures for variations
- Clear naming for fixture purposes (e.g., `createFutureEvent` vs `createPastEvent`)

**Test Data Lifecycle**:
- When to update test data: When app features change that affect test scenarios
- How to document test data assumptions: Add comments in fixtures explaining assumptions
- Versioning strategy: Keep fixtures simple; version when major feature changes occur

### Async Operation Testing

**Decision**: Use pumpAndSettle() and explicit waits for async operations.

**Rationale**:
- Flutter tests require proper async handling
- Provider state updates are async
- File I/O and network operations are async
- Explicit waits make test intent clear

**Implementation**:
```dart
await tester.pumpWidget(app);
await tester.pumpAndSettle();  // Wait for all animations and async ops

// For specific async operations
await tester.runAsync(() async {
  await eventProvider.addEvent(event);
});
await tester.pumpAndSettle();
```

### Widget Testing in Integration Tests

**Decision**: Test widgets through user interactions, not direct property access.

**Rationale**:
- Integration tests should simulate real user behavior
- Testing through interactions catches more integration issues
- Direct property access is better suited for widget tests
- Makes tests more robust to implementation changes

**Implementation**:
```dart
// Good: Test through interaction
await tester.tap(find.byType(FloatingActionButton));
await tester.enterText(find.byKey(Key('eventTitle')), 'Meeting');
await tester.tap(find.text('Save'));

// Avoid: Direct property access
// final dialog = tester.widget<EventFormDialog>(...);
// dialog.title = 'Meeting';
```

### Theme Testing Approach

**Decision**: Test theme changes during interactions and across app restarts.

**Rationale**:
- Theme provider state affects entire app
- Need to verify theme persistence
- Need to verify widgets respond to theme changes
- Existing theme tests are basic, need expansion

**Implementation**:
- Test theme toggle with various widgets open
- Test theme changes during form editing
- Test theme persistence across app "restarts" (re-pumpWidget)
- Test theme response to system theme changes

### Performance Testing Strategy

**Decision**: Use simple timing assertions for basic performance verification.

**Rationale**:
- Full performance benchmarking is out of scope
- Basic timing checks catch major regressions
- Integration tests should not be flaky due to tight timing
- Focus on "fast enough" rather than exact numbers

**Implementation**:
```dart
testWidgets('Large event set loads quickly', (tester) async {
  final stopwatch = Stopwatch()..start();

  await addManyEvents(100);
  await pumpApp();

  await tester.pumpAndSettle();
  stopwatch.stop();

  expect(stopwatch.elapsedMilliseconds, lessThan(5000));
});
```

**Test Execution Time Budgets**:
- Each integration test file should run in under 30 seconds
- Total test suite should complete in under 8 minutes
- Performance tests should have clear time budgets (e.g., "<5s" for loading 100 events)
- Monitor execution times and refactor slow tests

### Accessibility Testing Approach

**Decision**: Use Flutter's semantics and accessibility APIs.

**Rationale**:
- Ensures app is usable by all users
- Flutter provides built-in accessibility testing support
- Catches accessibility regressions early
- Required for app store submissions

**Implementation**:
```dart
testWidgets('Buttons have accessible labels', (tester) async {
  final buttonFinder = find.byType(FloatingActionButton);

  expect(
    getSemantics(buttonFinder).label,
    isNotEmpty,
    reason: 'Add button should have accessibility label',
  );
});
```

**Accessibility Scope**:
- Semantic labels for all interactive elements
- Keyboard navigation support
- Minimum touch target sizes (48x48px)
- Screen reader compatibility (through semantic labels)
- Exclude: Dynamic type scaling, screen reader specific testing (unless essential)

### Gesture Testing Approach

**Decision**: Test common user gestures beyond simple taps.

**Rationale**:
- Users interact with apps through various gestures
- Ensures gesture recognition works correctly
- Catches issues with scroll, long-press, drag interactions

**Implementation**:
- Test long-press for context menus (if applicable)
- Test drag/swipe for calendar navigation
- Test scroll for lists
- Verify gestures don't interfere with taps

### Responsive Layout Testing Approach

**Decision**: Test app behavior across different screen sizes and orientations.

**Rationale**:
- App supports multiple platforms with varying screen sizes
- Users rotate devices between portrait and landscape
- Layout issues on different sizes frustrate users

**Implementation**:
- Test calendar display in portrait and landscape
- Test event list scrolling on small screens
- Test dialogs adapt to different screen sizes
- Verify no layout overflow or clipping

### Platform Testing Strategy

**Decision**: Use Linux as primary platform for integration tests with manual testing for platform-specific features.

**Rationale**:
- Core app functionality is platform-independent (Flutter, Provider, state management)
- Linux provides fast, reliable test execution
- Platform-specific features are limited (Android back button, iOS navigation bar)
- Manual testing covers platform-specific behaviors more effectively than automated tests

**Implementation**:
- All integration tests run on Linux (primary development platform)
- Platform-specific features documented in manual testing checklist:
  - Android: Back button behavior, permission requests, notification channels
  - iOS: Navigation bar, permission dialogs, background fetch
  - Cross-platform: Notification behavior differences, file system paths
- Manual testing checklist created and maintained in docs/
- Automated tests focus on core functionality that's consistent across platforms

**Platform-Specific Features Excluded from Automated Testing**:
- Android system back button navigation
- iOS swipe-to-go-back gestures
- Platform-specific permission dialogs
- Platform-specific notification channels
- Platform-specific file picker behaviors

## Integration Points

### With Existing Test Infrastructure

- **test_helpers.dart**: Expand with integration test helpers (setupMockGitRepository, setupMockNotifications, setupMockCertificateService, cleanTestEvents)
- **setupTestEnvironment()**: Continue using for isolation
- **cleanupTestEnvironment()**: Continue using for cleanup
- **MCAL_TEST_CLEANUP**: Continue using for debugging

### With Production Code

- **EventProvider**: Test through UI interactions
- **ThemeProvider**: Test theme changes and persistence
- **SyncService**: Test through sync button workflows
- **NotificationService**: Test with proper mocking
- **CertificateService**: Test with proper mocking
- **Widgets**: Test through user interactions, not direct access

### With OpenSpec Requirements

- **testing spec**: Add new integration test requirements with cross-references
- **event-management spec**: Add event CRUD integration test requirements with cross-references
- **git-sync spec**: Add sync workflow integration test requirements with cross-references
- **notifications spec**: Add notification integration test requirements with cross-references
- **theme-system spec**: Add theme integration test requirements with cross-references
- **ui-calendar spec**: Add calendar interaction integration test requirements with cross-references

## Potential Trade-offs and Mitigations

### Trade-off 1: Test Execution Time vs. Coverage

**Issue**: More tests mean longer execution time.

**Mitigation**:
- Group tests logically for selective execution
- Use efficient mocking to avoid slow operations
- Set reasonable timeout for test suite (target: <8 minutes total)
- Each test file should run in under 30 seconds
- Document which test groups can be skipped during rapid development
- Create "smoke test" group for rapid feedback

### Trade-off 2: Mock Fidelity vs. Realism

**Issue**: Mocks may not perfectly match real service behavior.

**Mitigation**:
- Document mock behavior clearly
- Review mocks regularly for accuracy
- Manual testing with real services still valuable
- Consider contract testing if needed

### Trade-off 3: Test Complexity vs. Maintainability

**Issue**: Complex test fixtures may be hard to maintain.

**Mitigation**:
- Keep fixtures simple and focused
- Document fixture purposes and parameters
- Avoid over-parameterization
- Create specific fixtures for common patterns
- Review and refactor fixtures regularly

### Trade-off 4: Test Fragility vs. Robustness

**Issue**: Integration tests can be fragile to UI changes.

**Mitigation**:
- Use semantic selectors where possible
- Avoid tight coupling to implementation details
- Focus on user-visible behavior
- Keep tests up-to-date with code changes
- Use stable selectors in priority order (semantic > key > type > text)

### Trade-off 5: Platform Coverage vs. Development Speed

**Issue**: Testing on only Linux may miss platform-specific bugs.

**Mitigation**:
- Document platform-specific features requiring manual testing
- Create comprehensive manual testing checklist
- Focus automated tests on platform-independent functionality
- Acknowledge that platform-specific bugs are acceptable for integration test scope
- Manual testing still critical for platform-specific behaviors

## Future Considerations

1. **CI/CD Integration**: Tests should run in automated pipelines (future work)
2. **Device-Specific Testing**: May need platform-specific test adjustments if automated testing expands
3. **Visual Regression Testing**: May add screenshot-based tests in future
4. **Contract Testing**: May add tests for API/service contracts
5. **Test Metrics**: May track coverage and flakiness metrics over time
