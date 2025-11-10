# Change: Optimize Platform Docs Access for AI Agents

## Why
AI agents working on the MCAL project need to quickly access platform-specific development instructions, but the current structure in AGENTS.md and docs/ may not clearly guide them to the relevant files based on the platform they are working on.

## What Changes
- Restructured AGENTS.md to include a "Platform-Specific Instructions" section with @-prefixed file paths as plain text for optimal AI parsing.
- Updated docs/platforms/README.md for human readability with standard markdown links, removed AI-specific instructions.
- Created docs/platforms/AGENTS.md containing AI agent instructions with @-prefixed paths.
- Implemented linking best practices: added breadcrumbs to workflow files, table of contents with anchor links, consistent relative paths, and descriptive link text.
- Ensured all platform workflow files exist and are accessible via @ notation in AI contexts.

## Impact
- Affected specs: None (documentation optimization)
- Affected code: None
- Improves AI agent efficiency in following platform-specific workflows.