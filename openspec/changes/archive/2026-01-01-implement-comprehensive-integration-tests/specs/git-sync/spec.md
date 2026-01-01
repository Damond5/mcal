# ADDED|MODIFIED|REMOVED Requirements

## ADDED Requirements

### Requirement: The application SHALL Include Sync Workflow Integration Tests

The application SHALL include integration tests in `integration_test/sync_integration_test.dart` to verify end-to-end Git synchronization workflows through GUI, complementing existing unit tests in `test/sync_service_test.dart` (see also: `specs/testing/spec.md`).

#### Scenario: Initializing sync with HTTPS and credentials
Given app is displaying calendar
When user taps sync button and selects "Init Sync"
And user enters a valid HTTPS repository URL
And user enters a valid username and password
And user taps OK
Then repository is initialized
And credentials are stored securely
And a success message is displayed
And sync status returns "clean" when checked

#### Scenario: Initializing sync with SSH without credentials
Given app is displaying calendar
When user taps sync button and selects "Init Sync"
And user enters a valid SSH repository URL (git@host:path)
And user leaves username and password fields empty
And user taps OK
Then repository is initialized
And a success message is displayed
And sync status returns "clean" when checked

#### Scenario: Pulling changes from remote repository
Given sync is initialized and remote has changes
When user taps sync button and selects "Pull"
Then a loading indicator is displayed
And changes are fetched from remote
And events are reloaded in app
And a success message is displayed showing number of events loaded
And sync status returns "clean"

#### Scenario: Pushing local changes to remote repository
Given sync is initialized and local changes exist
When user taps sync button and selects "Push"
Then a loading indicator is displayed
And local changes are committed
And changes are pushed to remote
And a success message is displayed
And sync status returns "clean"

#### Scenario: Checking sync status
Given sync is initialized
When user taps sync button and selects "Status"
Then sync status dialog is displayed
And status is one of: "clean", "modified", "not initialized", or "syncing"
And dialog can be dismissed

#### Scenario: Updating credentials
Given sync is initialized with existing credentials
When user taps sync button and selects "Update Credentials"
And user enters a new username and password
And user taps OK
Then credentials are updated in secure storage
And a success message is displayed
And new credentials can be used for sync operations

#### Scenario: Sync initialization failure shows error
Given app is displaying calendar
When user taps sync button and selects "Init Sync"
And user enters an invalid repository URL
And user taps OK
Then an error message is displayed indicating failure
And sync status returns "not initialized"
And app remains functional

### Requirement: The application SHALL Include Conflict Resolution Integration Tests

The application SHALL include integration tests in `integration_test/conflict_resolution_integration_test.dart` to verify merge conflict resolution workflows through GUI (see also: `specs/testing/spec.md`).

#### Scenario: Conflict dialog appears on merge conflict
Given sync is initialized and a merge conflict occurs during pull
When pull operation detects a conflict
Then conflict resolution dialog is displayed
And dialog shows a message explaining conflict
And dialog is not dismissible by tapping outside
And three buttons are available: Cancel, Keep Local, Use Remote

#### Scenario: Keeping local changes on conflict
Given a conflict resolution dialog is displayed
When user taps "Keep Local"
Then merge operation is aborted
And local changes remain unchanged
And a success message is displayed indicating local changes were kept
And sync button can be used again

#### Scenario: Using remote changes on conflict
Given a conflict resolution dialog is displayed
When user taps "Use Remote"
Then merge conflict is resolved by preferring remote changes
And remote changes are applied
And a success message is displayed indicating pull was successful
And event list is updated with remote events
And sync button can be used again

#### Scenario: Canceling conflict resolution
Given a conflict resolution dialog is displayed
When user taps "Cancel"
Then dialog is closed
And merge conflict is not resolved
And app remains in a sync error state
And conflict resolution can be attempted again

### Requirement: The application SHALL Include Sync Settings Integration Tests

The application SHALL include integration tests in `integration_test/sync_settings_integration_test.dart` to verify sync settings configuration and persistence through GUI (see also: `specs/testing/spec.md`).

#### Scenario: Enabling auto sync
Given sync settings dialog is open
And auto sync is disabled
When user taps auto sync toggle
Then toggle switches to enabled state
And workmanager task is registered (mocked)
And toggle state persists after app restart

#### Scenario: Disabling auto sync
Given sync settings dialog is open
And auto sync is enabled
When user taps auto sync toggle
Then toggle switches to disabled state
And workmanager task is cancelled (mocked)
And toggle state persists after app restart

#### Scenario: Adjusting sync frequency
Given sync settings dialog is open
When user slides frequency slider
Then frequency label updates to show new value (in minutes)
And value is between 5 and 60 minutes
And frequency persists after app restart

#### Scenario: Enabling sync on resume
Given sync settings dialog is open
And sync on resume is disabled
When user taps resume sync toggle
Then toggle switches to enabled state
And toggle state persists after app restart
And auto-pull occurs when app is resumed (mocked)

#### Scenario: Saving sync settings
Given sync settings dialog is open
And user has modified one or more settings
When user taps Save
Then dialog closes
And all modified settings are persisted
And settings take effect immediately

#### Scenario: Canceling sync settings changes
Given sync settings dialog is open
And user has modified one or more settings
When user taps Cancel
Then dialog closes
And modified settings are not persisted
And original settings remain in effect
