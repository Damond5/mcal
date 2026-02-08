## REMOVED Requirements

### Requirement: Cross-platform commands for unsupported platforms removed

Description: Commands for platforms not currently supported or rarely used are removed from the Makefile.

#### Scenario: Platform-specific commands limited to supported platforms
- **WHEN** developer looks at available Makefile targets
- **THEN** only commands for actively supported platforms (Linux, Android) are present
- **AND** no commands for other platforms (iOS, macOS, Windows) are available

#### Scenario: Focus on primary development platforms
- **WHEN** developer is working on the project
- **THEN** they have access to commands for their target platform (Linux or Android)
- **AND** commands for unused platforms are not cluttering the Makefile
