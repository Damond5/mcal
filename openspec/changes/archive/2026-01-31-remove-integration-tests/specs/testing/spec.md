## REMOVED Requirements

### Requirement: The application SHALL Comprehensive Test Suite

**Reason**: Integration tests are being removed from the project. Unit tests and widget tests provide sufficient coverage for verifying core functionality. The integration test portion of this requirement is no longer applicable.

**Migration**: End-to-end workflows are verified through widget tests and manual testing before releases.

---

### Requirement: The application SHALL Test Execution

**Reason**: The scenario "Running integration tests" references integration tests which are being removed. This requirement is being updated to focus on unit and widget tests only.

**Migration**: The application continues to support running unit tests via `fvm flutter test test/`. Widget tests execute via the same command.

---

### Requirement: The application SHALL Theme Toggle Integration Tests

**Reason**: This entire requirement is being removed as it specifically references integration test file `integration_test/app_integration_test.dart` which is being deleted.

**Migration**: Theme toggle functionality continues to be verified through widget tests in `test/widget_test.dart` and unit tests in `test/theme_provider_test.dart`.

---

### Requirement: The application SHALL Test Cleanup and Isolation

**Reason**: The scenario "Integration test cleanup" references integration tests which are being removed. The remaining scenarios focus on unit test and widget test cleanup which is handled by `test/test_helpers.dart`.

**Migration**: Unit tests and widget tests continue to use proper cleanup mechanisms from `test/test_helpers.dart`. Integration test cleanup is no longer required.

---

### Requirement: The application SHALL Include Event CRUD Integration Tests

**Reason**: This entire requirement is being removed as it specifically references integration test file `integration_test/event_crud_integration_test.dart` which is being deleted.

**Migration**: Event CRUD functionality continues to be verified through unit tests in `test/event_provider_test.dart` and widget tests.

---

### Requirement: The application SHALL Include Calendar Interactions Integration Tests

**Reason**: This entire requirement is being removed as it specifically references integration test file `integration_test/calendar_integration_test.dart` which is being deleted.

**Migration**: Calendar interactions continue to be verified through widget tests and unit tests for EventProvider state management.

---

### Requirement: The application SHALL Include Event Form Dialog Integration Tests

**Reason**: This entire requirement is being removed as it specifically references integration test file `integration_test/event_form_integration_test.dart` which is being deleted.

**Migration**: Event form dialog functionality continues to be verified through widget tests.

---

### Requirement: The application SHALL Include Event List Widget Integration Tests

**Reason**: This entire requirement is being removed as it specifically references integration test file `integration_test/event_list_integration_test.dart` which is being deleted.

**Migration**: Event list widget functionality continues to be verified through widget tests.

---

### Requirement: The application SHALL Include Theme Integration Tests

**Reason**: This entire requirement is being removed as it references integration test file `integration_test/calendar_integration_test.dart` which is being deleted, and the scenarios describe integration test behavior.

**Migration**: Theme integration with UI components continues to be verified through widget tests and unit tests.

---

### Requirement: The application SHALL Provide Test Timing Utilities

**Reason**: This entire requirement is being removed as it specifically references integration test timing utilities which are being deleted along with the integration test infrastructure.

**Migration**: Unit tests and widget tests use standard Flutter testing timing mechanisms (`pumpAndSettle()`, `await` statements).

---

### Requirement: The application SHALL Provide Test Isolation Utilities

**Reason**: This entire requirement is being removed as it specifically references integration test isolation utilities which are being deleted along with the integration test infrastructure.

**Migration**: Unit tests continue to use test helpers from `test/test_helpers.dart` for proper isolation.

---

### Requirement: The application SHALL Provide Error Injection Framework

**Reason**: This entire requirement is being removed as it specifically references integration test error injection which is being deleted along with the integration test infrastructure.

**Migration**: Error handling is tested through unit tests that can throw exceptions directly.

---

### Requirement: The application SHALL Provide Test Data Factories

**Reason**: This entire requirement is being removed as it specifically references integration test data factories which are being deleted along with the integration test infrastructure.

**Migration**: Unit tests create test data directly using the Event model constructors.

---

### Requirement: The application SHALL Ensure Test Determinism

**Reason**: The scenario "Tests handle concurrent operations safely" references integration test synchronization utilities which are being deleted. The remaining scenarios about deterministic test execution remain applicable.

**Migration**: The requirement is reduced to the core determinism scenarios which apply to all test types.

---

### Requirement: The application SHALL Test Window Configuration

**Reason**: This entire requirement is being removed as it specifically references integration test window configuration (`setupTestWindowSize()`, `resetTestWindowSize()`) which is being deleted along with the integration test infrastructure.

**Migration**: Widget tests use standard Flutter test window configuration when needed.
