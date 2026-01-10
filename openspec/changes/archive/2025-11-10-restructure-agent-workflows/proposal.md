# Change: Restructure AGENTS.md to split platform development workflows

## Why
The current AGENTS.md file contains detailed development workflow instructions only for Android, but the project supports multiple platforms (Android, iOS, Linux, macOS, Web, Windows). As the project grows, having all platform-specific workflows in one file will become unwieldy and hard to maintain. Splitting these into separate files per platform will improve organization and make it easier for agents to find relevant instructions.

## What Changes
- Create a new `docs/platforms/` directory in the project root to house platform-specific workflow files
- Move the existing Android Development Workflow section from AGENTS.md to `docs/platforms/android-workflow.md`
- Create placeholder workflow files for other platforms with a standard template: `docs/platforms/ios-workflow.md`, `docs/platforms/linux-workflow.md`, `docs/platforms/macos-workflow.md`, `docs/platforms/web-workflow.md`, `docs/platforms/windows-workflow.md`
- Update AGENTS.md to reference these separate files using relative paths and provide a brief overview of the platform workflow structure
- Search for and update any external references to the Android workflow section in other files

## Impact
- Affected files: AGENTS.md (restructured), new files under `docs/platforms/`, README.md (updated project structure)
- No impact on application code or specs
- Improves maintainability of agent instructions as the project adds more platform-specific guidance