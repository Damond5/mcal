<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

OpenSpec is a specification system used in this project for managing change proposals and project guidelines.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

The @/ notation refers to the project's openspec/ directory.

This block is auto-managed and should not be edited manually.

<!-- OPENSPEC:END -->

# Platform Development Workflows

The MCAL project supports multiple platforms (Android, iOS, Linux, macOS, Web, Windows). Platform-specific development workflows are organized in separate files under the `docs/platforms/` directory for better maintainability.

- [Android Workflow](docs/platforms/android-workflow.md)
- [iOS Workflow](docs/platforms/ios-workflow.md)
- [Linux Workflow](docs/platforms/linux-workflow.md)
- [macOS Workflow](docs/platforms/macos-workflow.md)
- [Web Workflow](docs/platforms/web-workflow.md)
- [Windows Workflow](docs/platforms/windows-workflow.md)
