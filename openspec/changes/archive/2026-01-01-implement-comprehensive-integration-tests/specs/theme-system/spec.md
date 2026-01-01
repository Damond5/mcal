# ADDED|MODIFIED|REMOVED Requirements

## ADDED Requirements

### Requirement: The application SHALL Include Theme Integration Tests

The application SHALL include integration tests in `integration_test/calendar_integration_test.dart` to verify theme changes work correctly during user interactions and all widgets respond appropriately, extending existing unit tests in `test/theme_provider_test.dart` and `integration_test/app_integration_test.dart` (see also: `specs/testing/spec.md`).

#### Scenario: Theme toggle changes entire app theme
Given app is loaded in light mode
When user taps theme toggle button
Then app switches to dark mode
And all UI elements update to dark theme colors
And theme toggle button icon changes to Icons.light_mode

#### Scenario: Theme toggle during event form open preserves form state
Given event form dialog is open with filled fields
When user taps theme toggle button
Then theme changes (light ↔ dark)
And event form dialog colors update to match new theme
And all form fields retain their values
And form remains open and functional

#### Scenario: Theme toggle during event details open preserves details
Given event details dialog is open
When user taps theme toggle button
Then theme changes (light ↔ dark)
And event details dialog colors update to match new theme
And all event information remains displayed
And dialog remains open and functional

#### Scenario: Calendar colors update on theme change
Given calendar is displayed in light mode
When user taps theme toggle button
Then theme changes to dark mode
And calendar background color updates to dark background
And calendar text color updates to light text
And event marker colors update to dark theme secondary color
And selected day decoration updates to dark theme primary color
And today decoration updates to dark theme primary color with opacity

#### Scenario: Event list colors update on theme change
Given event list is displaying events in light mode
When user taps theme toggle button
Then theme changes to dark mode
And event list background color updates to dark background
And event card background colors update to dark theme surface color
And event card text colors update to light text
And all icons and buttons in event list update colors

#### Scenario: Buttons and icons update on theme change
Given app is displayed in light mode
When user taps theme toggle button
Then theme changes to dark mode
And sync button icon color updates to dark theme on-surface color
And FAB icon color updates to dark theme on-primary color
And all other buttons update their colors appropriately
And all icons update their colors appropriately

#### Scenario: Theme persists across app restart
Given app is in dark mode
When app widget is reloaded (simulating restart)
Then dark theme is restored
And all UI elements display in dark mode
And theme toggle button shows Icons.light_mode icon

#### Scenario: System theme changes are detected
Given app is in system theme mode
When system theme changes from light to dark
Then app switches to dark mode
And all UI elements update to dark theme colors
And theme toggle button icon updates to Icons.light_mode

#### Scenario: Theme toggle cycles correctly
Given app is in system theme mode
When user taps theme toggle button once
Then app switches to light mode
And when user taps theme toggle button again
Then app switches to dark mode
And when user taps theme toggle button third time
Then app returns to system theme mode
