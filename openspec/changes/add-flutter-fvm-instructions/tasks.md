## Implementation Tasks

- [x] **Review existing AGENTS.md structure and content**
    - Examine the current AGENTS.md file to understand the existing documentation structure, formatting conventions, and sections related to Flutter development
    - Identify how other platform-specific sections are documented (Linux, Android, Native Rust)
    - Note the current Makefile integration patterns and command documentation style
    - Review any existing references to Flutter or fvm in the codebase
    - Understand the target audience and level of technical detail expected

- [x] **Document current Flutter commands and Makefile integration**
    - Review the Makefile to identify all Flutter-related targets
    - Document the relationship between Makefile commands and underlying Flutter/fvm commands
    - Identify which Makefile commands can be replaced or augmented with fvm equivalents
    - Map existing Makefile targets to their corresponding Flutter SDK commands
    - Note any environment variables or configuration requirements

- [x] **Verify fvm installation and available Flutter versions**
    - Check if fvm is installed in the development environment
    - List available Flutter versions configured with fvm
    - Verify the Flutter version currently in use by the project
    - Document any version-specific considerations or requirements
    - Test fvm command availability and basic functionality

- [x] **Research best practices for fvm command documentation**
    - Review official fvm documentation for command syntax and options
    - Identify common use cases and workflows for fvm in team environments
    - Document recommended practices for version pinning and consistency
    - Research error handling and troubleshooting approaches
    - Note any security considerations for fvm usage

- [x] **Create "Flutter Development (fvm)" section structure**
- [x] **Add fvm setup and installation instructions**
- [x] **Document basic fvm commands (list, use, flutter)**
- [x] **Add fvm commands for running Flutter applications**
- [x] **Add fvm commands for building Flutter applications (Linux, Android, iOS, Web)**
- [x] **Add fvm commands for testing Flutter applications**
- [x] **Add fvm commands for analyzing Flutter code**
- [x] **Add fvm commands for formatting Flutter code**
- [x] **Add fvm commands for maintenance tasks (clean, deps, generate)**
- [x] **Add platform-specific fvm command documentation**
- [x] **Document integration with existing Makefile commands**
    - Compare fvm direct commands versus Makefile wrapper commands
    - Document when to use each approach and why
    - Include Makefile target mapping to fvm equivalents
    - Add guidance on maintaining consistency between approaches
    - Document any hybrid workflows that combine both methods

- [x] **Review all fvm commands for accuracy**
- [x] **Verify all commands work with current fvm setup**
- [x] **Check documentation consistency and formatting**
- [x] **Validate examples are clear and accurate**
- [x] **Ensure cross-platform compatibility documentation**
- [x] **Test fvm setup instructions on clean environment**
- [x] **Test all documented fvm commands**
- [x] **Verify Makefile integration works correctly**
    - Test Makefile targets that reference Flutter/fvm commands
    - Verify environment variable propagation through Makefile
    - Test parallel execution and dependency handling
    - Confirm clean and rebuild scenarios work properly
    - Validate Makefile documentation accuracy

- [x] **Test documentation clarity with team members**
    - Share documentation draft with development team members
    - Collect feedback on clarity, completeness, and accuracy
    - Identify areas requiring additional explanation or examples
    - Validate terminology matches team conventions
    - Incorporate team feedback into final documentation
