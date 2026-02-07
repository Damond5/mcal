# Flutter FVM Development Workflow Specification

This specification defines the requirements and implementation details for integrating Flutter Version Management (fvm) into the MCAL project development workflow. The goal is to ensure consistent Flutter versions across all development environments while maintaining seamless integration with existing Makefile infrastructure.

## Overview

The MCAL project is a cross-platform application built with Flutter and Rust, targeting multiple platforms including Linux, Android, iOS, and Web. To ensure consistency across development environments and prevent version-related issues, this specification mandates the use of Flutter Version Management (fvm) for all Flutter-related operations. fvm allows multiple Flutter versions to be installed concurrently and enables project-specific Flutter version selection, ensuring that all team members use the exact same Flutter version for a given project.

This specification covers three primary areas: standardized Flutter version management through fvm, integration with existing Makefile infrastructure, and comprehensive command documentation for all common development tasks. By following this specification, developers will have a clear understanding of how to set up their environment, execute Flutter commands, and maintain consistency throughout the development lifecycle.

The implementation of this specification will result in updated documentation (specifically AGENTS.md) that provides clear, actionable guidance for all Flutter development operations. Developers will no longer need to wonder which Flutter version to use or how to execute commands correctly—fvm ensures the correct version is always active, and the Makefile provides convenient shortcuts for common operations.

---

## ADDED Requirements

### Requirement: Standardized Flutter Version Management using fvm

Description: All developers must use fvm to manage Flutter versions, ensuring consistent development environment across team members. The documentation must show fvm-prefixed commands for all Flutter operations, making it explicit which Flutter version is being used and ensuring that all team members execute commands with identical Flutter versions regardless of their global installations.

This requirement addresses the fundamental challenge of maintaining consistency in Flutter development environments. Without a standardized approach, team members may have different Flutter versions installed globally, leading to subtle bugs, inconsistent behavior, and difficult-to-diagnose issues. fvm solves this by allowing the project to specify a particular Flutter version, which is then used consistently by all developers when working on the project.

The fvm approach provides several benefits beyond consistency. It allows for testing against multiple Flutter versions without affecting the global installation, enables gradual upgrades across the team, and provides isolation between projects that may require different Flutter versions. By prefixing all Flutter commands with `fvm`, the documentation makes it immediately clear which version is being used, reducing confusion and preventing accidental use of the wrong version.

#### Scenario: Setting up the development environment with fvm

- **WHEN** a new developer joins the project and needs to set up their development environment
- **THEN** they should install fvm, configure the project to use the correct Flutter version, and verify that all subsequent Flutter commands use the fvm-managed version

The setup process begins with installing fvm itself, which is a straightforward process that can be accomplished through various package managers including Homebrew, Chocolatey, or pub global activation. Once fvm is installed, the developer needs to install the Flutter version specified by the project, which is typically stored in a configuration file such as `.fvm/fvm_config.json` or declared in `pubspec.yaml` with the `fvm` field.

After installing the required Flutter version, the developer should configure their IDE to use the fvm-managed Flutter SDK rather than any globally installed version. For Visual Studio Code, this involves setting the `flutterSdkPath` in workspace settings to point to the fvm cache directory. For Android Studio or IntelliJ IDEA, the Flutter SDK path should be configured to use the fvm-managed version.

Verification of the setup is crucial to ensure that the environment is correctly configured. This includes running `fvm flutter doctor` to diagnose any configuration issues, checking that `fvm flutter --version` returns the expected version, and confirming that the fvm version is active when running commands from the project directory.

#### Scenario: Running Flutter applications using fvm

- **WHEN** a developer needs to run a Flutter application for development or testing purposes
- **THEN** they should use fvm-prefixed Flutter commands to ensure the correct Flutter version is used

Running Flutter applications with fvm requires prefixing the standard Flutter command with `fvm`. For example, instead of running `flutter run`, the developer should run `fvm flutter run`. This ensures that the project-specific Flutter version is used regardless of any globally installed versions.

The fvm command works by resolving the Flutter version configured for the current project (by looking at the `.fvm` directory or configuration files) and then executing the corresponding Flutter command from that version's installation. This process is transparent to the user—the `fvm flutter` command behaves exactly like a regular Flutter command, but with the correct version guaranteed.

For hot reload and hot restart functionality during development, developers should use `fvm flutter run` with the appropriate device targeting. The fvm prefix applies to all Flutter commands, including those invoked through IDE integrations when properly configured. Developers should verify that their IDE is configured to use the fvm path for Flutter operations.

#### Scenario: Building Flutter applications for different platforms

- **WHEN** a developer needs to build the Flutter application for deployment or testing on different platforms
- **THEN** they should use fvm-prefixed Flutter build commands to ensure the correct Flutter version and build tools are used

Building Flutter applications requires the correct Flutter version to ensure compatibility between the application code and the build tools. Using fvm guarantees that the build process uses the same Flutter version as the development environment, preventing subtle differences that might cause build failures or runtime issues.

For Android builds, developers should use commands like `fvm flutter build apk`, `fvm flutter build appbundle`, or `fvm flutter build ipa` (for release builds). For Linux desktop builds, `fvm flutter build linux` produces the Linux executable. For web deployments, `fvm flutter build web` generates the web artifacts.

The Makefile targets that invoke these build commands should be updated to include the fvm prefix, ensuring that all build operations—whether invoked through Make or directly—use the correct Flutter version. This consistency is essential for CI/CD pipelines where the environment may differ from developer machines.

#### Scenario: Running Flutter tests using fvm

- **WHEN** a developer needs to execute unit tests, widget tests, or integration tests
- **THEN** they should use fvm-prefixed Flutter test commands to ensure test execution uses the correct Flutter version

Test execution with fvm requires using `fvm flutter test` instead of the standard `flutter test` command. This ensures that the test environment matches the development environment, which is critical for test reliability and consistency across team members.

Developers can run all tests with `fvm flutter test`, run specific test files by providing paths, or use the `--coverage` flag to generate code coverage reports. The fvm prefix applies to all test-related commands, including `fvm flutter test --update-goldens` for golden file tests and `fvm flutter drive` for integration tests.

For CI/CD pipelines, test commands must also use the fvm prefix to ensure consistency with local development and to catch any version-related issues during the automated testing process. The Makefile should provide convenient targets like `fvm-test` that wrap these commands appropriately.

#### Scenario: Analyzing Flutter code using fvm

- **WHEN** a developer needs to check their Flutter code for errors, warnings, or style issues
- **THEN** they should use fvm-prefixed Flutter analyze commands to ensure the analysis uses the correct Flutter version's linter rules and analyzer configuration

Code analysis with fvm uses the `fvm flutter analyze` command, which invokes the Dart analyzer using the Flutter version configured for the project. This ensures that the analysis rules match those expected by the project, including any custom linter rules or analyzer options configured in `analysis_options.yaml`.

The `fvm flutter analyze` command accepts the same arguments as the standard `flutter analyze` command, including directory or file paths to analyze. Developers should run this command regularly during development to catch issues early, and CI/CD pipelines should include it as part of the quality checks.

The Makefile should provide convenient targets for analysis that wrap the fvm commands appropriately, such as `make analyze` which invokes `fvm flutter analyze` with appropriate arguments. This makes it easy for developers to run analysis without needing to remember the exact command syntax.

#### Scenario: Formatting Flutter code using fvm

- **WHEN** a developer needs to format their Flutter code to conform to the project's style guidelines
- **THEN** they should use fvm-prefixed Flutter format commands to ensure formatting uses the correct Flutter version's formatter

Code formatting with fvm requires using `fvm flutter format` instead of `flutter format`. This ensures that the formatting follows the exact version of the Dart formatter used by the project, maintaining consistency across all developers' contributions.

The format command accepts individual files or directories as arguments and modifies the files in place to conform to the Dart style guide. Developers should run `fvm flutter format .` in their project directory to format all Dart files, or target specific files as needed.

Pre-commit hooks or CI checks should verify that all submitted code is properly formatted using the correct Flutter version. The Makefile should provide a `make format` target that wraps the fvm format command for convenient execution.

---

### Requirement: Integration with Existing Makefile Infrastructure

Description: The fvm instructions must integrate seamlessly with the existing Makefile commands in AGENTS.md, providing clear documentation on how fvm commands relate to Make targets. Developers should be able to use either fvm commands directly or Make targets conveniently, with both approaches guaranteed to use the correct Flutter version.

This requirement addresses the need for convenience while maintaining correctness. The existing Makefile provides a convenient abstraction layer for common development tasks, and developers should not need to remember complex command sequences. At the same time, the documentation should provide enough detail that developers understand what's happening under the hood and can execute fvm commands directly when needed.

The integration should be bidirectional: Make targets should transparently use fvm, and the documentation should show both the direct fvm command and the equivalent Make target. This allows developers to choose their preferred approach—whether they want the convenience of Make or the explicitness of direct fvm commands.

#### Scenario: Make commands automatically use the correct Flutter version via fvm

- **WHEN** a developer executes a Make target that involves Flutter commands
- **THEN** the Makefile should internally use fvm to ensure the correct Flutter version is used, without requiring the developer to remember to prefix commands

The Makefile must be updated to wrap all Flutter-related commands with fvm. This means that targets like `linux-run`, `android-build`, `analyze`, and `test` should execute commands like `fvm flutter run`, `fvm flutter build apk`, `fvm flutter analyze`, and `fvm flutter test` respectively.

The implementation approach should use Make's ability to invoke shell commands, with each Flutter-related command prefixed by `fvm `. For example, the `linux-run` target might be defined as `fvm flutter -d linux`, and the `analyze` target as `fvm flutter analyze .`.

Developers should not need to modify their workflow when switching from direct Flutter commands to Make targets—the Make targets should produce identical results but with the consistency guarantee of fvm. The Makefile should handle all the complexity of fvm invocation transparently.

#### Scenario: Documentation shows both fvm direct commands and Make equivalents

- **WHEN** developers consult the AGENTS.md documentation for guidance on Flutter operations
- **THEN** they should find both the direct fvm command and the equivalent Make target for each operation, allowing them to choose their preferred approach

The documentation should present commands in a clear format that shows both approaches. For example, for running the application on Linux, the documentation might show:

- Direct command: `fvm flutter -d linux`
- Make equivalent: `make linux-run`

This dual presentation helps developers understand that they have options while making both approaches discoverable. The documentation should explain when each approach might be preferred—Make targets for convenience during development, fvm commands for scripting or when Make is not available.

The documentation should maintain consistency in its presentation format, using clear headings and code blocks to distinguish between command types. Each command should include a brief explanation of what it does and any important considerations.

#### Scenario: Verification commands to confirm fvm setup is correct

- **WHEN** a developer wants to verify that their fvm and Makefile integration is correctly configured
- **THEN** they should have access to verification commands that check the fvm installation, Flutter version, and Makefile configuration

The documentation should provide a comprehensive set of verification commands that developers can run to diagnose issues with their development environment. These commands should check:

- fvm installation and version (`fvm --version`)
- Correct Flutter version is installed (`fvm flutter --version`)
- The fvm version is active in the current directory (`fvm use` or checking `.fvm` configuration)
- Make targets exist and are executable (`make -n <target>` for dry-run)
- The relationship between fvm commands and Make targets

Additionally, a convenience target like `make verify-deps` should be available to run all verification checks automatically. This target might execute `fvm flutter doctor`, check the fvm configuration, and verify that required Make targets exist.

---

### Requirement: Comprehensive Command Documentation

Description: All common Flutter development tasks must be documented with fvm commands, providing clear examples and explanations for each operation. The documentation should serve as a complete reference for developers, covering everything from initial setup to advanced development and maintenance tasks.

This requirement ensures that developers have a single, authoritative source of truth for Flutter development commands. The documentation should be comprehensive enough that developers rarely need to consult external resources for common operations, while still linking to official documentation for advanced or rare use cases.

The documentation should be organized logically, starting with installation and setup, progressing through development workflows, and ending with maintenance and troubleshooting. Each command should include practical examples showing common use cases and output expectations.

#### Scenario: Installation and setup commands

- **WHEN** developers need to set up their development environment from scratch
- **THEN** they should find step-by-step instructions covering fvm installation, Flutter version configuration, IDE setup, and verification procedures

The installation documentation should cover multiple operating systems and installation methods, recognizing that developers may have different preferences and constraints. For each approach, the documentation should provide complete, copy-pasteable commands with explanations.

Key installation steps include:
- Installing fvm using Homebrew (`brew tap kodaline/fvm && brew install fvm`), Chocolatey, or pub global activation
- Installing the required Flutter version using `fvm install <version>` or automatically through `fvm use`
- Configuring the IDE to use the fvm-managed Flutter SDK
- Verifying the setup with `fvm flutter doctor` and `fvm flutter --version`
- Installing project dependencies with `fvm flutter pub get`

The documentation should also cover common installation issues and their solutions, such as path configuration problems, permission issues, and IDE configuration errors.

#### Scenario: Development workflow commands

- **WHEN** developers need to perform common development tasks during their daily work
- **THEN** they should find documented fvm commands for running, building, testing, and analyzing their Flutter applications

Development workflow documentation should cover the full spectrum of activities developers perform regularly. This includes:

- Running the application during development with hot reload: `fvm flutter run` with device selection
- Building debug and release versions: `fvm flutter build apk --debug`, `fvm flutter build linux --release`
- Running unit and widget tests: `fvm flutter test`
- Generating code: `fvm flutter pub run build_runner build`
- Managing packages: `fvm flutter pub get`, `fvm flutter pub outdated`

Each command should include explanations of common flags and options, such as device selection (`-d linux`, `-d android`), build modes (`--debug`, `--release`), and output customization.

The documentation should also cover common development patterns, such as running with specific Dart defines for configuration, using flavor configurations for different build variants, and enabling debugging features.

#### Scenario: Maintenance commands

- **WHEN** developers need to maintain code quality, clean build artifacts, or perform routine maintenance tasks
- **THEN** they should find documented fvm commands for formatting, linting, cleaning, and other maintenance operations

Maintenance documentation should cover all commands related to code quality and project maintenance:

- Code formatting: `fvm flutter format .` for the entire project or specific files
- Static analysis: `fvm flutter analyze` with directory or file arguments
- Code generation: `fvm flutter pub run build_runner build` for JSON serialization, etc.
- Dependency updates: `fvm flutter pub upgrade` and `fvm flutter pub outdated`
- Cleaning build artifacts: `fvm flutter clean`
- Resetting development state: `fvm flutter clean && fvm flutter pub get`

The documentation should explain when each command should be used and what the expected outcomes are. It should also cover best practices for maintenance, such as running analysis before commits and formatting code before creating pull requests.

#### Scenario: Platform-specific commands for Android, iOS, Linux, Web

- **WHEN** developers need to build for specific target platforms
- **THEN** they should find platform-specific fvm commands with appropriate flags and configurations for each target platform

Platform-specific documentation should provide detailed guidance for each supported platform, including:

**Android:**
- Building APKs: `fvm flutter build apk`
- Building App Bundles: `fvm flutter build appbundle`
- Building for specific architectures: `fvm flutter build apk --target-platform android-arm64`
- Running on Android device/emulator: `fvm flutter -d android`

**iOS:**
- Building iOS archives: `fvm flutter build ipa`
- Building for simulator: `fvm flutter build ios --simulator`
- Running on iOS simulator: `fvm flutter -d ios`

**Linux:**
- Building Linux executables: `fvm flutter build linux`
- Running on Linux desktop: `fvm flutter -d linux`
- Linux-specific configuration and dependencies

**Web:**
- Building web artifacts: `fvm flutter build web`
- Running in browser: `fvm flutter -d chrome`
- Web-specific build options and considerations

For each platform, the documentation should cover installation of platform-specific dependencies, common build issues and solutions, and any platform-specific considerations that developers should be aware of when building for that target.

---

## Implementation Notes

### fvm Configuration

The project should include fvm configuration that specifies the required Flutter version. This is typically accomplished through a `.fvm/fvm_config.json` file that specifies the Flutter version, along with a `.fvm/flutter_sdk` symbolic link that points to the correct version within the fvm cache.

The fvm configuration should be committed to version control so that new developers can run `fvm use` to automatically install and configure the correct Flutter version. The `.fvm` directory should be included in the repository's `.gitignore` file to avoid committing the actual Flutter SDK, but the configuration files should be tracked.

### Makefile Updates

The existing Makefile targets should be reviewed and updated to include fvm prefixes for all Flutter commands. The updated Makefile should:

- Use `fvm flutter` instead of `flutter` for all Flutter commands
- Provide clear documentation within Makefile comments
- Include convenience targets that combine related operations
- Handle errors appropriately and provide useful error messages

### Documentation Maintenance

The AGENTS.md file should be updated to reflect the fvm-based workflow. The documentation should:

- Show fvm-prefixed commands as the primary approach
- Provide Make equivalents for convenience targets
- Include verification commands for environment setup
- Be reviewed and updated when Flutter or fvm versions change

### Training and Adoption

Team members should be informed about the fvm workflow and provided with training if necessary. The transition from non-fvm to fvm-based workflows should be gradual, with support available for developers who encounter issues during the adoption period.

---

## Success Criteria

The implementation of this specification will be considered successful when:

1. All Flutter commands in AGENTS.md use fvm prefixes
2. All Makefile targets that invoke Flutter commands use fvm internally
3. New developers can set up their environment using only the project documentation
4. All common development tasks have documented fvm commands
5. Platform-specific build commands are documented for all supported targets
6. Verification commands are available to diagnose environment issues
7. The workflow has been tested by at least two team members and documented feedback has been incorporated

---

## Related Documentation

- Flutter Version Management (fvm) Official Documentation: https://fvm.app
- Flutter Official Documentation: https://docs.flutter.dev
- MCAL Project AGENTS.md: See existing Makefile targets and platform-specific commands
- Dart Documentation: https://dart.dev

---

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-02-07 | MCAL Development Team | Initial specification document |

---

## References

This specification references and builds upon the following resources:

- Flutter Version Management (fvm) - Primary tool for Flutter version management
- MCAL Project AGENTS.md - Existing Makefile infrastructure documentation
- Flutter Official Documentation - Best practices for Flutter development workflows
- Industry standards for development environment consistency
