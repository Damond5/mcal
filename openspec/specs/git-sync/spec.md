# git-sync Specification

## Purpose
TBD - created by archiving change incorporate-existing-docs. Update Purpose after archive.
## Requirements
### Requirement: The application SHALL Git Repository Management
The application SHALL support initializing new Git repositories and cloning existing ones with authentication support for HTTPS and SSH.

#### Scenario: Initializing new repository
Given a local path for event storage
When user initiates sync setup
Then a new Git repository is initialized at that path

#### Scenario: Cloning remote repository
Given a remote Git URL with credentials
When cloning
Then the repository is cloned locally with authentication

#### Scenario: Handling SSH authentication failure
Given invalid SSH key path
When Git operation attempted
Then authentication error is displayed with guidance

### Requirement: The application SHALL Git Operations Support
The application SHALL implement comprehensive Git operations via Rust backend: init, clone, current_branch, list_branches, pull, push, status, add_remote, fetch, checkout, add_all, commit, merge_prefer_remote, merge_abort, stash, diff.

#### Scenario: Pulling with local changes
Given an initialized repository with uncommitted local changes
When pull is executed
Then local changes are temporarily stashed, remote changes are applied including deletions, and local changes are restored for non-deleted files; local changes to deleted files are discarded
And if stash pop fails due to conflicts, deletions remain enforced as remote state is preserved</content>
<parameter name="filePath">openspec/changes/fix-git-pull-deletion-handling/specs/git-sync/spec.md

### Requirement: The application SHALL Authentication Handling
Git operations SHALL support separate username/password/token for HTTPS and SSH key paths, with secure storage and dynamic injection.

#### Scenario: HTTPS authentication
Given username and password/token
When Git operation requires auth
Then credentials are temporarily embedded in URL for the operation

#### Scenario: SSH authentication
Given SSH key path
When Git operation requires auth
Then key-based authentication is used

### Requirement: The application SHALL Conflict Resolution
Merge conflicts during pull SHALL be handled programmatically, with UI options to prefer remote, keep local, or cancel.

#### Scenario: Resolving merge conflict
Given a merge conflict during pull
When user chooses "prefer remote"
Then remote changes are applied and committed

#### Scenario: Aborting merge
Given an ongoing merge operation
When user chooses abort
Then the merge is cancelled and repository returns to previous state

### Requirement: The application SHALL Auto Sync Functionality
The application SHALL support automatic syncing: pulls on app start if initialized, pushes after event CRUD operations.

#### Scenario: Auto pull on start
Given sync is initialized and app launches
When 5+ minutes since last sync
Then changes are automatically pulled from remote

#### Scenario: Auto push after changes
Given an event is created/updated/deleted
When operation completes
Then local changes are automatically pushed to remote

### Requirement: The application SHALL Sync Settings
Auto sync SHALL be configurable: enable/disable, frequency (5-60 minutes), sync on app resume.

#### Scenario: Configuring auto sync
Given user accesses sync settings
When they set frequency to 15 minutes
Then periodic sync occurs every 15 minutes on supported platforms

### Requirement: The application SHALL Branch Handling
The application SHALL support dynamic detection of current and default branches for Git operations, correctly stripping "refs/heads/" prefixes from remote default branches to use short branch names, or using the full ref if the prefix is not present.

#### Scenario: Dynamic branch detection
Given a repository with a default branch (e.g., "refs/heads/main")
When performing Git operations without a local HEAD
Then the remote default branch is detected, prefix is stripped, and the short name ("main") is used for operations

#### Scenario: Handling non-standard refs
Given a repository with default branch "refs/tags/v1.0"
When performing Git operations without a local HEAD
Then the full ref is used if prefix stripping fails</content>
<parameter name="filePath">openspec/changes/correct-git-branch-name-handling/specs/git-sync/spec.md

### Requirement: The application SHALL Platform-Specific Sync
Background sync SHALL use workmanager on Android/iOS and Timer on Linux.

#### Scenario: Mobile background sync
Given Android device with workmanager
When auto sync is enabled
Then periodic sync runs in background using workmanager

#### Scenario: Linux sync
Given Linux platform
When auto sync is enabled
Then Timer is used for periodic checks

### Requirement: The application SHALL SSL Certificate Handling
Git operations over HTTPS SHALL support custom CA certificates by reading system certificates cross-platform and configuring them in the Rust git2 backend. The certificate handling SHALL be tested with a hybrid testing approach:

- Unit tests with full mocking for cross-platform test execution during `flutter test`
- Platform-specific integration tests for Android and iOS that run on real devices
- Tests verify certificate caching, error handling, and integration with SyncService
- Tests verify end-to-end flow from platform certificate reading to Rust git2 backend configuration
- Tests skip appropriately on platforms without certificate channel implementations (Linux, macOS, Windows, Web)

Unit tests in `test/certificate_service_test.dart` SHALL mock the certificate MethodChannel and test CertificateService logic. Integration tests in `integration_test/certificate_integration_test.dart` SHALL run on Android/iOS devices and verify actual platform certificate reading.

#### Scenario: Unit tests verify certificate caching with mocked channel
Given a unit test is running on any platform
And certificate channel is mocked to return test certificates
When `getSystemCACertificates()` is called
Then platform channel is invoked and returns test data
And result is cached for subsequent calls
And when called again, cached data is returned without channel invocation

#### Scenario: Unit tests verify error handling with mocked channel
Given a unit test is running on any platform
And certificate channel is mocked to throw exception
When `getSystemCACertificates()` is called
Then exception is caught and logged
And empty list is returned
And certificate service does not crash

#### Scenario: Unit tests verify SyncService integration
Given a unit test is running on any platform
And certificate service is mocked to return test certificates
When SyncService.initSync() is called
Then certificate service.getSystemCACertificates() is invoked
And if certificates returned, Rust API set_ssl_ca_certs() is invoked
And if no certificates, fallback to default SSL behavior

#### Scenario: Integration tests verify real certificate reading on Android
Given an integration test is running on Android device or emulator
And sync is initialized
Then system CA certificates are read from AndroidCAStore
And certificates are in valid PEM format
And certificates are passed to Rust set_ssl_ca_certs() function
And log message indicates number of certificates loaded

#### Scenario: Integration tests verify real certificate reading on iOS
Given an integration test is running on iOS device or simulator
And sync is initialized
Then system CA certificates are read from SecTrustCopyAnchorCertificates
And certificates are in valid PEM format
And certificates are passed to Rust set_ssl_ca_certs() function
And log message indicates number of certificates loaded

#### Scenario: Integration tests verify error handling on real devices
Given an integration test is running on Android or iOS
And platform certificate channel throws exception
When sync initialization is attempted
Then exception is caught and logged
And fallback to default SSL behavior occurs
And sync initialization completes successfully
And application remains functional

#### Scenario: Integration tests skip on unsupported platforms
Given an integration test is running on Linux, macOS, Windows, or Web
And platform does not have certificate channel implementation
When certificate integration tests execute
Then tests are skipped before execution
And no errors are logged
And test suite continues to next test

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

