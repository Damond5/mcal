## Implementation Tasks

### Phase 0: Add Platform-Agnostic Makefile Targets

- [x] Add `build` target that runs `fvm flutter build`
  - Flutter auto-detects current platform (Linux builds for Linux, macOS for macOS)
  - Add descriptive comment block explaining purpose
  - No platform detection logic needed - Flutter handles it

- [x] Add `test` target that runs `fvm flutter test`
  - Works on any platform
  - Add descriptive comment block explaining purpose

- [x] Add `clean` target that runs `fvm flutter clean`
  - Works on any platform
  - Add descriptive comment block explaining purpose

- [x] Test platform-agnostic targets
  - Run `make build` and verify Flutter builds for current platform
  - Run `make test` and verify tests execute correctly
  - Run `make clean` and verify build cache is cleared

- [x] Add platform detection logic for libs only
  - `libs` target is the only one that needs platform-specific Rust compilation
  - Use simple conditional: if Android architectures exist, call android-libs
  - Add descriptive comment block

### Phase 1: Add Linux Makefile Targets

- [x] Add `linux-libs` target to Makefile
  - Compile Rust native libraries for x86_64-unknown-linux-gnu
  - Output to appropriate directory for Linux Flutter integration
  - Add descriptive comment block explaining purpose and prerequisites

- [x] Add `linux-build` target to Makefile
  - Depend on `linux-libs` for native library compilation
  - Regenerate Flutter-Rust Bridge if Rust sources changed
  - Run `fvm flutter build linux` for desktop build
  - Add descriptive comment block with usage instructions

- [x] Add `linux-test` target to Makefile
  - Run `fvm flutter test` on Linux platform
  - Add descriptive comment block explaining when to use

- [x] Add `linux-clean` target to Makefile
  - Clean Flutter build cache for Linux
  - Clean Rust build artifacts for Linux
  - Add descriptive comment block

- [x] Verify existing Android targets still work after additions
  - Run `make android-build` and confirm APK generation
  - Run `make android-test` and confirm test execution

### Phase 2: Simplify AGENTS.md

- [x] Create simplified AGENTS.md content
  - Detect platform from environment context (e.g., `platform: linux`)
  - Provide direct Makefile target references:
    - Android build: `make android-build`
    - Linux build: `make linux-build`
    - Android test: `make android-test`
    - Linux test: `make linux-test`
  - Reference Makefile for complete command documentation
  - Remove all references to `docs/platforms/` paths

- [x] Replace existing AGENTS.md with simplified version
  - Keep essential agent instructions
  - Remove indirection through workflow files
  - Add brief platform detection guidance

### Phase 3: Delete docs/ Directory

- [x] Verify essential content has been migrated to Makefile comments
  - Android troubleshooting notes
  - Build automation guidance
  - Platform-specific command documentation

- [x] Delete entire `docs/` directory and all subdirectories
  - Remove `docs/platforms/` and all platform workflow files
  - Remove `docs/platforms/README.md`
  - Remove `docs/platforms/AGENTS.md`
  - Remove `docs/platforms/manual-testing-checklist.md`
  - Remove `docs/platforms/platform-testing-strategy.md`

- [x] Update any remaining documentation references to removed paths
  - Check README.md for docs/ links and update if necessary
  - Check any other documentation files for references

### Phase 4: Verification

- [x] Verify all Makefile targets are documented with comments
  - Review each target has descriptive comment block
  - Confirm platform applicability is clear
  - Verify prerequisites are documented

- [x] Test Linux build workflow
  - Run `make linux-libs` and verify Rust compilation
  - Run `make linux-build` and verify Flutter build
  - Run `make linux-test` and verify tests execute

- [x] Test Android build workflow
  - Run `make android-libs` and verify all architectures compile
  - Run `make android-build` and verify APK generation
  - Run `make android-test` and verify tests execute

- [x] Verify AGENTS.md works correctly
  - Confirm simplified instructions are clear
  - Confirm all Makefile targets are referenced
  - Verify no broken links to removed documentation

### Phase 5: Documentation Updates

- [x] Update README.md if it references removed docs/ paths
  - Remove any links to `docs/platforms/` directory
  - Update any platform-specific navigation instructions

- [x] Add entry to CHANGELOG.md
  - Document the simplification of agent workflows
  - Note the removal of docs/ directory
  - Mention new Linux Makefile targets
