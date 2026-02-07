# Flutter FVM Development Workflow Specification

## Overview

This specification defines the standardized Flutter development workflow using Flutter Version Management (FVM) for the MCAL project. FVM ensures consistent Flutter versions across all developers and CI/CD pipelines, preventing version-related inconsistencies and deployment issues.

## Purpose

The primary objectives of this workflow specification are:

1. **Version Consistency**: Guarantee all team members use identical Flutter versions
2. **Build Reproducibility**: Ensure CI/CD pipelines produce consistent builds
3. **Development Efficiency**: Streamline Flutter version switching and management
4. **Dependency Alignment**: Match Flutter SDK versions with project dependencies

## Core Principles

### Version Locking

All Flutter projects must use FVM to lock the Flutter SDK version. This approach provides:

- Deterministic builds across all environments
- Easy rollback capabilities for troubleshooting
- Clean separation between system Flutter and project Flutter
- Simplified onboarding for new team members

### Environment Isolation

Each project maintains its own Flutter version configuration, preventing conflicts between different projects that may require different Flutter versions.

## Workflow Components

### 1. Project Configuration

#### Flutter Version File

The project must include an `.fvm/fvm_config.json` file that specifies the exact Flutter version:

```json
{
  "flutterSdkVersion": "3.24.0",
  "flavors": {}
}
```

This file is version controlled and ensures all developers use the same version.

#### Version Specification

The Flutter version is defined in `pubspec.yaml` under environment constraints:

```yaml
environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.24.0"
```

### 2. Installation Procedures

#### Initial Setup

New developers must follow these steps to set up the development environment:

1. Install FVM globally:
   ```bash
   dart pub global activate fvm
   ```

2. Install the project Flutter version:
   ```bash
   fvm install
   ```

3. Verify installation:
   ```bash
   fvm flutter --version
   ```

4. Install project dependencies:
   ```bash
   fvm flutter pub get
   ```

#### Version Management

To switch Flutter versions:

```bash
# List available versions
fvm list

# Install a specific version
fvm install <version>

# Use a specific version for the project
fvm use <version>
```

### 3. Development Commands

All Flutter commands should use FVM to ensure version consistency:

#### Running the Application

```bash
# Linux development
fvm flutter run -d linux

# Android development
fvm flutter run -d android

# Release builds
fvm flutter build apk --release
```

#### Testing

```bash
# Run all tests
fvm flutter test

# Run tests with coverage
fvm flutter test --coverage

# Run specific test file
fvm flutter test test/unit/auth_test.dart
```

#### Code Quality

```bash
# Analyze code
fvm flutter analyze

# Format code
fvm flutter format .

# Run linter
fvm flutter lint
```

### 4. CI/CD Integration

#### Pipeline Configuration

The CI/CD pipeline must use FVM to ensure consistent builds:

```yaml
stages:
  - setup
  - build
  - test
  - deploy

install_fvm:
  stage: setup
  script:
    - dart pub global activate fvm
    - fvm install
    - fvm flutter pub get

run_tests:
  stage: test
  script:
    - fvm flutter test
```

#### Build Verification

Each build must verify FVM synchronization:

```bash
# Verify correct Flutter version is active
fvm flutter --version

# Ensure dependencies are up to date
fvm flutter pub get

# Run build verification
fvm flutter build apk --debug
```

### 5. Team Workflow

#### Onboarding New Developers

1. Clone the repository
2. Install FVM globally
3. Run `fvm install` to install the project Flutter version
4. Run `fvm flutter pub get` to install dependencies
5. Verify setup with `fvm flutter doctor`

#### Adding New Dependencies

When adding new Flutter dependencies:

1. Add the dependency to `pubspec.yaml`
2. Run `fvm flutter pub get` to install
3. Update `fvm.lock` file to track the version
4. Commit both `pubspec.yaml` and `fvm.lock`

#### Updating Flutter Version

To update the Flutter version for the project:

1. Research the target version's compatibility
2. Update `.fvm/fvm_config.json`
3. Run `fvm install` to install the new version
4. Verify all dependencies work correctly
5. Update `pubspec.yaml` environment constraints
6. Test thoroughly before merging

### 6. Makefile Integration

The project Makefile provides convenient wrappers for FVM commands:

```makefile
# Flutter Version Management
fvm-install:
    dart pub global activate fvm
    fvm install

# Development
linux-run:
    fvm flutter run -d linux

linux-build:
    fvm flutter build linux

# Testing
test:
    fvm flutter test

test-cov:
    fvm flutter test --coverage

# Quality
analyze:
    fvm flutter analyze

format:
    fvm flutter format .
```

## Best Practices

### 1. Version Control

- Always commit `.fvm/fvm_config.json` to version control
- Commit `fvm.lock` to track exact dependency versions
- Never commit `.fvm/flutter_sdk/` directory

### 2. Performance Optimization

- Use `fvm flutter clean` before major rebuilds
- Cache FVM installations across builds
- Use `--cached` flag for faster builds when appropriate

### 3. Troubleshooting

If encountering version-related issues:

1. Verify FVM installation: `fvm --version`
2. Check active version: `fvm flutter --version`
3. Reinstall version: `fvm install <version>`
4. Clear FVM cache: `fvm remove <version> && fvm install <version>`

### 4. Security Considerations

- Only use official Flutter channels (stable, beta, dev)
- Verify Flutter SDK integrity after installation
- Keep FVM updated to latest version
- Review dependency changes before updating

## Verification Procedures

### Pre-Commit Verification

Before committing changes:

1. Run `fvm flutter analyze` to ensure no errors
2. Run `fvm flutter test` to verify tests pass
3. Verify build works: `fvm flutter build apk --debug`

### Build Verification

To verify build synchronization:

```bash
# Check Flutter version matches project config
fvm flutter --version

# Verify dependencies are installed
fvm flutter pub deps | grep -E "^[└├]" | head -20

# Run a simple build test
fvm flutter build apk --debug --quiet
```

### Environment Verification

To verify the development environment:

```bash
# Full Flutter doctor output
fvm flutter doctor -v

# Check FVM configuration
cat .fvm/fvm_config.json

# List installed FVM versions
fvm list
```

## Troubleshooting Common Issues

### Issue: FVM Not Found

**Problem**: `fvm: command not found`

**Solution**:
```bash
# Ensure FVM is in PATH
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Or reinstall FVM
dart pub global activate fvm
```

### Issue: Version Mismatch

**Problem**: Different Flutter versions detected

**Solution**:
```bash
# Check active version
fvm flutter --version

# Reinstall correct version
fvm install
fvm use <version>
```

### Issue: Dependency Conflicts

**Problem**: Dependency resolution failures

**Solution**:
```bash
# Clean and reinstall
fvm flutter clean
fvm flutter pub get

# Upgrade dependencies
fvm flutter pub upgrade
```

### Issue: Build Failures

**Problem**: Build errors after version change

**Solution**:
```bash
# Clear build artifacts
fvm flutter clean

# Reinstall dependencies
fvm flutter pub get

# Rebuild
fvm flutter build apk
```

## References

### External Documentation

- [FVM Official Documentation](https://fvm.app/)
- [Flutter Version Management Guide](https://docs.flutter.dev/development/tools/sdk/upgrading)
- [Flutter Build Performance](https://docs.flutter.dev/testing/build-performance)

### Related Specifications

- [Development Environment Setup](../development-environment-setup/spec.md)
- [CI/CD Pipeline Specification](../ci-cd-pipeline/spec.md)
- [Code Quality Standards](../code-quality-standards/spec.md)

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-01-15 | Initial specification |

## Compliance

This specification must be followed by all team members working on Flutter-related development. Deviations require approval from the technical lead and must be documented.

---

**Last Updated**: 2024-01-15
**Maintained By**: Development Team
