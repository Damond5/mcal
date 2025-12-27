# Tasks: Add Theme Toggle Integration Test

## Implementation Tasks

- [x] 1. Add theme toggle integration test group
  - Create new test group `group('Theme Toggle Integration Tests', () { ... })` in `integration_test/app_integration_test.dart`
  - Follow existing pattern with `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`
  - Reference existing tests at lines 43-152 for pattern consistency

- [x] 2. Implement theme toggle button interaction test
  - Write test that verifies button exists and is tappable
  - Tap the button and verify theme mode changes using Provider state access
  - Verify button icon updates after tap using widget predicate finders
  - Use `find.byType(ThemeToggleButton)` and `tester.tap()`
  - Verify state persists by checking ThemeProvider instance

- [x] 3. Implement theme toggle cycle test
  - Write test that verifies theme toggles between light and dark modes
  - Tap button multiple times and verify theme mode cycles
  - Verify button icon matches each theme mode state (Icons.brightness_6, Icons.light_mode, Icons.dark_mode)
  - Test transitions: system → light → dark → light

- [x] 4. Implement theme persistence test
  - Write test that sets theme to dark mode
  - Reload app widget to simulate restart (re-pump with new Provider instance)
  - Verify dark theme is restored from SharedPreferences
  - Verify button icon reflects persisted theme
  - Ensure SharedPreferences mock is reset between tests

- [x] 5. Implement visual theme changes test
  - Write test that verifies UI elements reflect theme changes
  - Tap theme toggle and verify Material widget properties or text colors update
  - Verify calendar or other theme-aware widgets update
  - Use widget predicates to check color properties match expected theme colors

- [x] 6. Run all tests locally
  - Run integration tests: `fvm flutter test integration_test/`
  - Run unit tests: `fvm flutter test`
  - Verify all new theme toggle integration tests pass
  - Verify all existing tests continue to pass (no regressions)

- [x] 7. Verify project builds successfully
  - Run `fvm flutter build apk --debug` on Android
  - Ensure no build errors or warnings
  - Verify integration tests can run on target device/emulator

- [x] 8. Perform code review using @review subagent
  - Request code review of new integration tests
  - Address all feedback from code review (implemented fixes for async initialization, persistence test, visual theme test)
  - Ensure all code follows project conventions
  - Verify test coverage is adequate

- [x] 9. Update CHANGELOG.md using @docs-writer subagent
  - Add entry under "Added" section
  - Follow Keep a Changelog format (www.keepachangelog.com)
  - Include version bump if needed per SemVer (www.semver.org)
  - Reference this change: "Theme toggle integration test coverage"

- [x] 10. Update README.md using @docs-writer subagent
  - Update testing section to reflect new integration test
  - Document theme toggle testing approach
  - Update coverage metrics if tracked
  - Update test files section to include integration_test/app_integration_test.dart

- [x] 11. Final validation
  - Re-run `openspec validate add-theme-toggle-integration-test --strict`
  - Ensure all validation checks pass
  - Verify proposal is ready for implementation approval

## Optional Tasks (Recommended)

- [ ] Manual verification
  - Run the app manually
  - Tap theme toggle button
  - Verify theme changes visually
  - Close and reopen app
  - Verify theme persists
