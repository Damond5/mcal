## 1. Restructure AGENTS.md
- [x] Add "Platform-Specific Instructions" section at the top of AGENTS.md
- [x] Include logic for AI agents to detect current platform (e.g., from env or context)
- [x] Provide direct file paths using @ notation (e.g., @docs/platforms/android-workflow.md)
- [x] Ensure section is prominently placed

## 2. Update docs/platforms/README.md
- [x] Add guidance on how AI agents should access platform instructions
- [x] Include a table mapping platforms to workflow files with @-prefixed paths
- [x] Emphasize reading the specific workflow before platform-specific tasks

## 3. Implement @ Notation for Links
- [x] Update all Markdown links in AGENTS.md and docs/ to use @ notation for file paths
- [x] Ensure @docs/ prefix for documentation paths, maintaining relative links
- [x] Add explanation of @ notation for AI agents

## 4. Apply Additional Linking Best Practices
- [x] Use reference-style links for bulk references to improve parseability
- [x] Add table of contents with anchor links in key documents for hierarchical navigation
- [x] Ensure all links use descriptive text and avoid generic phrases like "click here"
- [x] Add breadcrumbs to workflow files for better navigation context

## 5. Validate Platform Workflow Files
- [x] Check that all platform workflow files exist and are up-to-date
- [x] Ensure links in README are correct and follow best practices
- [x] Test that AI agents can follow the @-prefixed paths and navigation aids (manual verification)