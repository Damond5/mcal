## ADDED Requirements

### Requirement: AGENTS.md provides direct Makefile references

Description: The AGENTS.md file must be simplified to point agents directly to Makefile targets instead of navigating through multiple documentation files. Agents should be able to find all build, test, and run commands from a single location.

#### Scenario: Agent needs to find Android build commands
- **WHEN** an agent reads AGENTS.md
- **THEN** the file provides clear instructions to use `make android-build` for Android APK builds
- **THEN** the file explains the prerequisites (Rust toolchain, Flutter, cargo-ndk)
- **THEN** the file references the Makefile for detailed target documentation

#### Scenario: Agent needs to find Linux build commands
- **WHEN** an agent reads AGENTS.md
- **THEN** the file provides clear instructions to use `make linux-build` for Linux desktop builds
- **THEN** the file explains any Linux-specific prerequisites
- **THEN** the file references the Makefile for detailed target documentation

#### Scenario: Agent needs to find test commands
- **WHEN** an agent reads AGENTS.md
- **THEN** the file provides clear test commands for both Android (`make android-test`) and Linux (`make linux-test`)
- **THEN** the file indicates when to use each platform's test commands

### Requirement: docs/ folder is completely removed

Description: The entire docs/ directory and all its subdirectories and files must be deleted. All essential documentation content must be migrated to Makefile comments or remain in README.md and CHANGELOG.md.

#### Scenario: Old documentation paths no longer exist
- **WHEN** an agent or user navigates to `docs/platforms/`
- **THEN** the path does not exist (404 or equivalent)
- **THEN** no orphaned documentation files remain

#### Scenario: Essential documentation is preserved
- **WHEN** an agent needs to understand the project structure
- **THEN** README.md remains in the project root with overview and navigation
- **THEN** CHANGELOG.md remains in the project root with version history
- **THEN** Makefile contains build command documentation via comments

#### Scenario: Build and test workflows continue to work
- **WHEN** an agent runs any Makefile target
- **THEN** all commands execute successfully without documentation dependencies
- **THEN** no references to removed docs/ paths cause errors

### Requirement: Documentation maintenance burden is reduced

Description: By consolidating documentation into Makefile comments and simplifying AGENTS.md, the ongoing maintenance burden of platform-specific workflow documentation should be reduced.

#### Scenario: Adding a new platform requires minimal documentation
- **WHEN** a new platform is added to MCAL
- **THEN** the agent needs to add only the Makefile target with appropriate comments
- **THEN** AGENTS.md only needs to reference the new Makefile target
- **THEN** no separate platform workflow document is required

#### Scenario: Updating a build command requires single location change
- **WHEN** a build command changes for any platform
- **THEN** the agent updates only the Makefile target
- **THEN** AGENTS.md continues to reference the same target
- **THEN** no synchronization across multiple documentation files is needed
