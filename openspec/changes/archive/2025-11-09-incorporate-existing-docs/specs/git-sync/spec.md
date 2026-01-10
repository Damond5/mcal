## ADDED Requirements

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

#### Scenario: Pulling changes
Given an initialized repository
When pull is executed
Then remote changes are fetched and merged, handling fast-forward merges

#### Scenario: Pushing commits
Given local commits exist
When push is executed
Then commits are pushed to the remote repository

#### Scenario: Checking repository status
Given a repository with changes
When status is requested
Then a list of modified, staged, and untracked files is returned

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
Git operations SHALL dynamically detect and use the current branch, supporting modern repositories with "main" or custom branch names.

#### Scenario: Dynamic branch detection
Given a repository with default branch "main"
When operations are performed
Then "main" is used instead of hardcoded "master"

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