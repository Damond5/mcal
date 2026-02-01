## Context

The MCAL project currently has fragmented agent workflow documentation:
- AGENTS.md directs agents to `docs/platforms/<platform>-workflow.md`
- The `docs/platforms/` directory contains 10 files, 4 of which are incomplete skeletons (21 lines each)
- Only Android has comprehensive Makefile targets; Linux lacks equivalent targets
- Content duplication exists (68 lines of duplication in android-workflow.md)
- This fragmentation increases maintenance burden and slows agent onboarding

## Goals / Non-Goals

**Goals:**
- Consolidate all agent build/test/run commands into a single location (Makefile)
- Add missing Linux Makefile targets to match Android capabilities
- Simplify AGENTS.md to point directly at Makefile targets
- Remove the `docs/` directory entirely
- Migrate essential documentation content to Makefile comments
- Add platform-agnostic Makefile targets that auto-detect current host platform

**Non-Goals:**
- Modify application functionality (events, sync, notifications unchanged)
- Add new platforms beyond Android and Linux
- Rewrite README.md or CHANGELOG.md content
- Change the existing Rust or Dart codebase structure
- Support for platforms other than Android and Linux in platform-agnostic targets (may add later)

## Decisions

### 1. Single Source of Truth: Makefile

The Makefile will become the authoritative source for all build, test, and run commands.

**Rationale:**
- Makefiles are self-documenting build tools familiar to developers and AI agents
- Eliminates the need for separate workflow documentation files
- Enables `make <target>` for all platform operations
- Comments within Makefile serve as documentation replacement

**Alternatives considered:**
- Keep docs/platforms workflow files: Rejected because it perpetuates fragmentation and duplication
- Create a single COMMANDS.md file: Rejected because it adds another file to maintain; Makefile is already the command source

### 2. AGENTS.md Points to Makefile Targets

AGENTS.md will be simplified to provide platform detection guidance and direct Makefile target references.

**Rationale:**
- Agents can quickly find commands without navigating through multiple files
- Makes AGENTS.md a quick reference rather than comprehensive documentation
- Reduces documentation maintenance to a single location

**Content structure:**
```markdown
# Agent Instructions

## Platform Detection
- Check `platform: linux` in environment for current platform

## Build Commands
- Generic (auto-detect): `make build`
- Explicit: `make android-build` or `make linux-build`

## Test Commands  
- Generic (auto-detect): `make test`
- Explicit: `make android-test` or `make linux-test`

## See Also
- Makefile for complete command reference with comments
```

### 3. docs/ Directory Deleted

The entire `docs/` directory and all subdirectories will be removed.

**Rationale:**
- Content is redundant with Makefile commands and README.md
- Several files are incomplete placeholders (skeletons with 21 lines)
- Reduces confusion about where to find authoritative information

**Migration of essential content:**
- Android troubleshooting content → Makefile comments
- Build automation notes → Makefile comments
- Platform-specific instructions → Makefile targets with comments
- Testing checklists → Move to relevant test files or Makefile

### 4. Linux Makefile Targets Added

Linux will receive equivalent Makefile targets to Android.

**New targets:**
- `make linux-build` - Build Linux desktop application with Rust native libs
- `make linux-test` - Run Flutter tests on Linux
- `make linux-libs` - Compile Rust native libraries for Linux only
- `make linux-clean` - Clean Linux build artifacts

**Implementation approach:**
- Mirror Android target structure for consistency
- Use `cargo build --release` for Linux Rust compilation
- Use `fvm flutter build linux` and `fvm flutter test` for Flutter commands

### 5. Makefile Comments as Documentation

Each Makefile target will include descriptive comment blocks.

**Comment structure:**
```makefile
# <Target Name>: <One-line description>
#
# Usage: make <target-name>
# Prerequisites: <what must exist before running>
# Platform: <Android|Linux|Both>
# Dependencies: <other targets this depends on>
```

### 6. Platform-Agnostic Makefile Targets

The Makefile will include generic targets that leverage Flutter's built-in platform detection. When running on Linux, `fvm flutter build` automatically builds for Linux; on macOS, it builds for macOS.

**New targets:**
- `make build` - Runs `fvm flutter build` (Flutter auto-detects host platform)
- `make test` - Runs `fvm flutter test` (works on any platform)
- `make clean` - Runs `fvm flutter clean` (works on any platform)

**Rationale:**
- Flutter's CLI already handles platform detection - no Makefile magic needed
- `fvm flutter build` without `-d` flag builds for current host by default
- Simplifies the common case: `make build` just works everywhere
- Explicit targets (`make android-build`, `make linux-build`) still available for CI/CD

**Example implementation:**
```makefile
# Platform-agnostic targets - Flutter handles detection
build:
	fvm flutter build

test:
	fvm flutter test

clean:
	fvm flutter clean
```

**Note:** The `libs` target remains platform-specific because Rust compilation targets differ:
- Android: `cargo ndk` for armeabi-v7a, arm64-v8a, x86, x86_64
- Linux: `cargo build --release` for x86_64-unknown-linux-gnu

## Risks / Trade-offs

**Risks:**
- Users with bookmarks to `docs/platforms/*` paths will encounter broken links
- Some platform-specific troubleshooting content may be harder to find without dedicated workflow documents
- Makefile comments may become outdated if targets change

**Mitigations:**
- Update any project documentation referencing removed paths
- Keep README.md with project overview and navigation
- Makefile comment updates required when targets change (part of normal development)

**Trade-offs:**
- **Reduced flexibility**: Single Makefile location means less platform-specific customization in documentation
- **Reduced duplication**: Better maintenance but potentially less hand-holding for platform-specific edge cases
- **Agent efficiency**: Faster command discovery at potential cost of comprehensive explanation availability
