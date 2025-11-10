# AI Agent Instructions for Platform Workflows

This file contains instructions specifically for AI agents working with platform-specific development workflows in the MCAL project.

## Platform Workflow Access

AI agents MUST:
1. Identify the target platform from task context or environment.
2. Read the corresponding workflow file listed in the table below before executing platform-specific actions.
3. Follow relative links within documents for portability.

## Workflow File Mapping

| Platform | Workflow File Path |
|----------|-------------------|
| Android | @docs/platforms/android-workflow.md |
| iOS | @docs/platforms/ios-workflow.md |
| Linux | @docs/platforms/linux-workflow.md |
| macOS | @docs/platforms/macos-workflow.md |
| Web | @docs/platforms/web-workflow.md |
| Windows | @docs/platforms/windows-workflow.md |

**@ Notation Explanation:**
The @ notation is used for AI-friendly linking to project documentation paths. For example, @docs/ refers to the docs/ directory.