## 1. Preparation

- [ ] 1.1 Verify no active work depends on integration tests
- [ ] 1.2 Review TODO.md for integration test related tasks
- [ ] 1.3 Document current integration test coverage summary

## 2. Remove Integration Test Directory

- [ ] 2.1 Remove `integration_test/accessibility_integration_test.dart`
- [ ] 2.2 Remove `integration_test/android_notification_delivery_integration_test.dart`
- [ ] 2.3 Remove `integration_test/app_integration_test.dart`
- [ ] 2.4 Remove `integration_test/calendar_integration_test.dart`
- [ ] 2.5 Remove `integration_test/certificate_integration_test.dart`
- [ ] 2.6 Remove `integration_test/conflict_resolution_integration_test.dart`
- [ ] 2.7 Remove `integration_test/edge_cases_integration_test.dart`
- [ ] 2.8 Remove `integration_test/event_crud_integration_test.dart`
- [ ] 2.9 Remove `integration_test/event_form_integration_test.dart`
- [ ] 2.10 Remove `integration_test/event_list_integration_test.dart`
- [ ] 2.11 Remove `integration_test/gesture_integration_test.dart`
- [ ] 2.12 Remove `integration_test/lifecycle_integration_test.dart`
- [ ] 2.13 Remove `integration_test/notification_integration_test.dart`
- [ ] 2.14 Remove `integration_test/performance_integration_test.dart`
- [ ] 2.15 Remove `integration_test/responsive_layout_integration_test.dart`
- [ ] 2.16 Remove `integration_test/sync_integration_test.dart`
- [ ] 2.17 Remove `integration_test/sync_settings_integration_test.dart`
- [ ] 2.18 Remove `integration_test/bulk_operations_performance_test.dart`

## 3. Remove Test Helper Files

- [ ] 3.1 Remove `integration_test/helpers/test_fixtures.dart`
- [ ] 3.2 Remove `integration_test/helpers/test_time_utils.dart`
- [ ] 3.3 Remove `integration_test/helpers/test_mock_enhancements.dart`
- [ ] 3.4 Remove `integration_test/helpers/test_isolation_utils.dart`
- [ ] 3.5 Remove `integration_test/helpers/test_data_factory.dart`
- [ ] 3.6 Remove `integration_test/helpers/test_timing_utils.dart`
- [ ] 3.7 Remove `integration_test/helpers/` directory

## 4. Remove Test Runner Scripts

- [ ] 4.1 Remove `scripts/test-integration-linux.sh`
- [ ] 4.2 Remove `scripts/test-integration-android.sh`

## 5. Remove Reports and Documentation

- [ ] 5.1 Remove `integration_test_report.md`
- [ ] 5.2 Remove `TEST_HELPERS_README.md`
- [ ] 5.3 Remove `TEST_INFRASTRUCTURE_FIXES.md`
- [ ] 5.4 Remove `SYNCHRONIZATION_UTILITIES.md`

## 6. Remove Fix Documentation

- [ ] 6.1 Remove `fixes/03_event_management_systemic_issues.md`
- [ ] 6.2 Remove `fixes/04_certificate_integration_test_failures.md`
- [ ] 6.3 Remove `fixes/05_conflict_resolution_test_failures.md`
- [ ] 6.4 Remove `fixes/06_edge_case_handling_improvements.md`
- [ ] 6.5 Remove `fixes/07_test_infrastructure_improvements.md`
- [ ] 6.6 Remove `fixes/08_test_timeout_configuration.md`
- [ ] 6.7 Remove `fixes/09_mocking_layer_enhancements.md`
- [ ] 6.8 Remove `fixes/10_test_coverage_analysis.md`

## 7. Update pubspec.yaml

- [ ] 7.1 Remove `integration_test: sdk: flutter` from dev_dependencies

## 8. Update Documentation

- [ ] 8.1 Update `README.md`:
  - Remove Integration Tests section
  - Remove Test Fixtures and Helpers section
  - Remove Test Execution Budget section (integration test references)
  - Remove Test Window Size Configuration section
  - Remove Known Test Limitations section
  - Remove Test Improvement Roadmap section
  - Remove "Test Infrastructure" subsection
  - Remove "Sync Settings Test Infrastructure Resolution" subsection
  - Remove "Event Management Systemic Issues Resolution" section (references integration tests)
  - Remove "Performance Optimizations" section (references integration_test/performance_integration_test.dart)
  - Remove "Integration Tests" from table of contents/quick links if present

- [ ] 8.2 Update `docs/platforms/platform-testing-strategy.md`:
  - Remove entire file or replace with simplified strategy without integration tests

- [ ] 8.3 Update `docs/platforms/manual-testing-checklist.md`:
  - Remove references to integration test results
  - Update platform-specific testing notes

## 9. Update OpenSpec Specifications

- [ ] 9.1 Update `openspec/specs/testing/spec.md`:
  - Remove "Requirement: The application SHALL Comprehensive Test Suite" (integration test references)
  - Remove "Requirement: The application SHALL Theme Toggle Integration Tests"
  - Remove "Requirement: The application SHALL Test Cleanup and Isolation" (integration test references)
  - Remove "Requirement: The application SHALL Include Event CRUD Integration Tests"
  - Remove "Requirement: The application SHALL Include Calendar Interactions Integration Tests"
  - Remove "Requirement: The application SHALL Include Event Form Dialog Integration Tests"
  - Remove "Requirement: The application SHALL Include Event List Widget Integration Tests"
  - Remove "Requirement: The application SHALL Include Theme Integration Tests"
  - Remove "Requirement: The application SHALL Provide Test Timing Utilities"
  - Remove "Requirement: The application SHALL Provide Test Isolation Utilities"
  - Remove "Requirement: The application SHALL Provide Error Injection Framework"
  - Remove "Requirement: The application SHALL Provide Test Data Factories"
  - Remove "Requirement: The application SHALL Ensure Test Determinism"
  - Update "Requirement: The application SHALL Test Coverage" to remove integration test references
  - Update "Requirement: The application SHALL Hybrid Testing Approach" to remove integration test references

- [ ] 9.2 Update `openspec/specs/integration-test-runner/spec.md`:
  - Remove entire specification file (archived to changes/archive)

## 10. Update TODO.md

- [ ] 10.1 Remove "Fix integration test failures" task
- [ ] 10.2 Remove "Integration tests stuck?" task
- [ ] 10.3 Remove "Integration Testing: Perform end-to-end tests..." task
- [ ] 10.4 Remove "Spec for ./SYNCHRONIZATION_UTILITIES.md" task
- [ ] 10.5 Remove "Add notes on test runtime..." tasks
- [ ] 10.6 Remove "Add notes on only running integration tests..." task

## 11. Update Makefile (if exists)

- [ ] 11.1 Remove `test-integration-linux` target
- [ ] 11.2 Remove `test-integration-android` target
- [ ] 11.3 Remove `test-integration-all` target

## 12. Validate Changes

- [ ] 12.1 Run `flutter analyze` to verify no integration test references remain
- [ ] 12.2 Run unit tests to verify they still pass: `flutter test test/`
- [ ] 12.3 Run widget tests to verify they still pass: `flutter test test/widget_test.dart`
- [ ] 12.4 Verify `pubspec.yaml` is valid
- [ ] 12.5 Verify project builds successfully: `flutter build apk` (or linux)
- [ ] 12.6 Run `openspec validate remove-integration-tests --strict`
- [ ] 12.7 Verify no remaining references to integration tests in documentation
