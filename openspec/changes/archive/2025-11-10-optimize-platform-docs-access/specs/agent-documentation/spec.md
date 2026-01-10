## ADDED Requirements
### Requirement: Platform Instruction Access
AI agents SHALL have clear guidance in AGENTS.md to access platform-specific instructions based on the current working platform, using @ notation for file paths and following linking best practices for parseability.

#### Scenario: Agent detects Linux platform
- **WHEN** AI agent is working on Linux platform
- **THEN** it reads @docs/platforms/linux-workflow.md for instructions

#### Scenario: Agent detects Android platform
- **WHEN** AI agent is working on Android platform
- **THEN** it reads @docs/platforms/android-workflow.md for instructions

### Requirement: AI-Friendly Linking
All documentation links SHALL use consistent formats, descriptive text, relative paths, and navigation aids to facilitate AI agent parsing and navigation.

#### Scenario: Consistent link formatting
- **WHEN** AI agent parses documentation
- **THEN** all links use @ notation for internal paths and descriptive text

#### Scenario: Navigation breadcrumbs
- **WHEN** AI agent reads a workflow file
- **THEN** it finds breadcrumb links for context and hierarchy