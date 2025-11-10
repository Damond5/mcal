## ADDED Requirements
### Requirement: Agent Instructions Organization
Agent instructions SHALL be organized in separate files per platform under `docs/platforms/` directory, with AGENTS.md providing relative path references to platform-specific workflow files using a standard template structure.

#### Scenario: Platform workflow lookup
- **WHEN** an agent needs platform-specific development instructions
- **THEN** AGENTS.md directs to the appropriate `docs/platforms/{platform}-workflow.md` file with working relative links