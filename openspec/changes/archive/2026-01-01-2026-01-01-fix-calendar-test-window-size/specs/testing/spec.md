# testing Specification Delta

## ADDED Requirements

### Requirement: The application SHALL Test Window Configuration
Integration tests SHALL configure test window size to ensure all UI elements (including AppBar action buttons) are visible and tappable during test execution:

- Tests SHALL use window size configuration helper `setupTestWindowSize()` in test setup
- Tests SHALL reset window size using `resetTestWindowSize()` in teardown
- Window size SHALL be set to 1200x800 pixels minimum to accommodate all AppBar elements
- Device pixel ratio SHALL be set to 1.0 for consistent sizing across platforms
- Window size configuration SHALL happen before `pumpWidget()` to take effect
- Tests SHALL NOT use `ensureVisible()` for AppBar elements (cannot scroll into viewport)

#### Scenario: Integration tests configure window size before widget pumping
Given a calendar integration test is executing
And test setup calls `setupTestWindowSize(tester)`
When `pumpWidget()` is called with MyApp widget
Then test window size is 1200x800 pixels
And device pixel ratio is 1.0
And all AppBar elements (SyncButton, ThemeToggleButton) are visible at layout time

#### Scenario: Integration tests reset window size after test execution
Given a calendar integration test has executed
And test teardown calls `resetTestWindowSize(tester)`
Then window size is reset to default values
And subsequent tests start with clean window state
And no test state pollution occurs between tests

#### Scenario: ThemeToggleButton is visible and tappable during tests
Given a test is executing with window size 1200x800
And AppBar is displayed with "MCal: Mobile Calendar" title + actions
When test layout is calculated after pumpWidget()
Then ThemeToggleButton is visible within viewport bounds
And ThemeToggleButton is not clipped at right edge
And ThemeToggleButton can be tapped by test framework
And tests can verify theme toggle functionality without skip flags

#### Scenario: Window size configuration works across platforms
Given an integration test is running on any platform (Linux, Android, iOS, macOS, Windows, Web)
And `setupTestWindowSize()` is called
Then window size is set to 1200x800 on all platforms
And device pixel ratio is 1.0 on all platforms
And test execution behavior is consistent across platforms
And UI elements are visible regardless of platform

#### Scenario: Window size configuration does not affect test isolation
Given multiple tests are executing in sequence
And each test calls `setupTestWindowSize()` and `resetTestWindowSize()`
Then each test has independent window state
And test execution does not depend on order
And no test pollutes window state for subsequent tests
And all tests execute consistently regardless of test file structure

#### Scenario: ensureVisible() is not used for AppBar elements
Given a test needs to interact with AppBar buttons
Then test SHALL NOT call `tester.ensureVisible(find.byType(ThemeToggleButton))`
Then test SHALL NOT call `tester.ensureVisible(find.byType(SyncButton))`
Then test SHALL rely on window size configuration for visibility
Then tests are not cluttered with ineffective workaround code
