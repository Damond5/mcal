## Context

The MCAL project currently has inconsistent build method documentation across multiple files:

- README.md uses `flutter` without `fvm` prefix in several places (inconsistent with platform workflows)
- README documents `flutter build web` even though web builds are not supported due to FFI incompatibility with Rust-based Git sync
- docs/platforms/linux-workflow.md references integration test runner scripts that were deleted in OpenSpec change 2026-01-31-remove-integration-tests
- Both Makefile and scripts/build-android.sh provide Android build automation (redundant)
- The build-deployment spec lacks formal requirements for build methods

The project uses Flutter Version Management (fvm) to ensure consistent Flutter SDK versions across development environments.

## Goals

- Ensure all Flutter commands in documentation use `fvm flutter` prefix for version consistency
- Remove misleading build method documentation that doesn't actually work
- Eliminate dead references to deleted scripts
- Establish Makefile as the primary build automation tool
- Add formal build method requirements to the build-deployment spec
- Clarify debug vs release build output locations
- Ensure all documentation accurately reflects current build capabilities

## Non-Goals

- No changes to actual build functionality or behavior
- No modifications to existing Makefile targets
- No removal of scripts/build-android.sh (only deprecation warning)
- No changes to android-workflow.md (it's already correctly formatted)
- No implementation code changes

## Decisions

### Decision 1: Standardize on `fvm flutter` prefix
**Rationale:** The platform workflows (android-workflow.md, etc.) consistently use `fvm flutter` prefix. The Makefile also uses `fvm flutter`. Only README.md has inconsistent usage. Standardizing on `fvm flutter` ensures all developers use the same Flutter version managed by fvm.

**Alternatives considered:**
- Use plain `flutter` everywhere: Rejected - would lose version consistency guarantees
- Mix both approaches: Rejected - would continue confusion
- Add FVM to all commands in scripts: Already done, need to update docs only

### Decision 2: Deprecate scripts/build-android.sh, keep Makefile
**Rationale:** The Makefile provides the same Android build automation in a more maintainable format. Makefiles are standard build automation tools that integrate well with development workflows. The shell script is redundant.

**Alternatives considered:**
- Keep both: Rejected - redundancy leads to maintenance burden
- Keep script, remove Makefile: Rejected - Makefile is more standard and maintainable
- Remove script completely: Rejected - may break existing user workflows, deprecation is safer

**Implementation:** Add deprecation warning comment at top of scripts/build-android.sh directing users to use `make android-build`

### Decision 3: Add build method requirements to build-deployment spec
**Rationale:** Currently the build-deployment spec has requirements for build configuration and validation, but no requirements for actual build methods. Adding these requirements ensures consistency and provides authoritative documentation of correct build methods.

**Alternatives considered:**
- Leave requirements in docs only: Rejected - specs should be authoritative
- Create new spec for build methods: Rejected - overkill, build-deployment is appropriate place

### Decision 4: Clarify web build status in documentation
**Rationale:** README.md currently shows `flutter build web` command that doesn't work. This is misleading and wastes user time. The documentation should clearly state web builds are not supported.

**Alternatives considered:**
- Fix web build support: Rejected - fundamental FFI incompatibility, out of scope
- Remove all web mentions: Rejected - should explain why it's not supported
- Keep misleading command: Rejected - wastes user time

## Migration Path

### For Documentation Updates
1. Update README.md Flutter commands to use `fvm flutter` prefix
2. Remove web build command from README or add prominent "NOT SUPPORTED" warning
3. Remove dead references from linux-workflow.md
4. Add deprecation warning to scripts/build-android.sh
5. Update platform status indicators in docs/platforms/README.md

### For OpenSpec Updates
1. Add new requirements to build-deployment spec
2. Ensure all requirements have scenarios
3. Validate with `openspec validate 2026-01-31-standardize-build-methods --strict`

## Risks / Trade-offs

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Users rely on scripts/build-android.sh | Medium | Medium | Add deprecation warning, keep script functional |
| Documentation updates miss some references | Low | Medium | Use grep to search for all Flutter command references |
| New spec requirements too restrictive | Low | Low | Keep requirements focused on standardization, not functionality |

## Open Questions

- None identified. All changes are straightforward documentation updates.

## References

- Previous change: `2026-01-31-remove-integration-tests` (removed test scripts referenced in linux-workflow.md)
- Build methods review: Comprehensive analysis of all build commands across project
- Current build-deployment spec: `openspec/specs/build-deployment/spec.md`
