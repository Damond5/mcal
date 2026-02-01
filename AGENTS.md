
# Platform-Specific Instructions

The MCAL project supports multiple platforms (Android, iOS, Linux, macOS, Web, Windows). Platform-specific development workflows are organized in separate files under the `docs/platforms/` directory for better maintainability.

## Platform Instruction Access for AI Agents

AI agents working on platform-specific tasks MUST first identify the current platform and read the corresponding workflow file. Use the following mapping to locate instructions:

| Platform | Workflow File Path | Status |
|----------|-------------------|--------|
| Android | docs/platforms/android-workflow.md | Available |
| iOS | docs/platforms/ios-workflow.md | Coming soon |
| Linux | docs/platforms/linux-workflow.md | Available |
| macOS | docs/platforms/macos-workflow.md | Coming soon |
| Web | docs/platforms/web-workflow.md | Coming soon |
| Windows | docs/platforms/windows-workflow.md | Coming soon |

**Navigation Guide:**
- README.md
- docs/platforms/README.md

**AI Agent Instructions:**
- Detect platform from environment context (e.g., `platform: linux` in env info).
- Read the linked workflow file before executing platform-specific commands.
- Use -prefixed paths for AI-friendly documentation access.
