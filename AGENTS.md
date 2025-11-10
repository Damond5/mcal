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

# Platform-Specific Instructions

The MCAL project supports multiple platforms (Android, iOS, Linux, macOS, Web, Windows). Platform-specific development workflows are organized in separate files under the `docs/platforms/` directory for better maintainability.

## Platform Instruction Access for AI Agents

AI agents working on platform-specific tasks MUST first identify the current platform and read the corresponding workflow file. Use the following mapping to locate instructions:

| Platform | Workflow File Path | Status |
|----------|-------------------|--------|
| Android | @docs/platforms/android-workflow.md | Available |
| iOS | @docs/platforms/ios-workflow.md | Coming soon |
| Linux | @docs/platforms/linux-workflow.md | Coming soon |
| macOS | @docs/platforms/macos-workflow.md | Coming soon |
| Web | @docs/platforms/web-workflow.md | Coming soon |
| Windows | @docs/platforms/windows-workflow.md | Coming soon |

**Navigation Guide:**
- @README.md
- @docs/platforms/README.md

**AI Agent Instructions:**
- Detect platform from environment context (e.g., `platform: linux` in env info).
- Read the linked workflow file before executing platform-specific commands.
- Use @-prefixed paths for AI-friendly documentation access.

**@ Notation Explanation:**
The @ notation is used for AI-friendly linking to project documentation paths. For example, @docs/ refers to the docs/ directory, and @/ refers to the openspec/ directory.
