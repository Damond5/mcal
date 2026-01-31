## Context

The MCAL project has accumulated a substantial integration testing infrastructure over time, including 18 integration test files, 8 helper utilities, 2 test runner scripts, and extensive supporting documentation. After evaluating the current state, it has been determined that this infrastructure is no longer providing sufficient value relative to its maintenance cost.

### Current State

- **260+ integration test scenarios** across 18 test files
- **~88% pass rate** with known flaky behavior
- **5-8 minutes execution time** for Linux integration tests
- **15-30 minutes execution time** for Android integration tests
- **Multiple documented infrastructure fixes** addressing systemic test failures
- **Complex test runner scripts** to workaround Flutter framework issues

### Problem Statement

The integration testing infrastructure suffers from several issues:

1. **Flaky Tests**: Despite significant infrastructure fixes, tests continue to exhibit flaky behavior with intermittent failures
2. **Maintenance Overhead**: Regular updates required to fix failing tests and maintain test isolation
3. **Platform Complexity**: Platform-specific test execution challenges requiring workaround scripts
4. **Execution Time**: Significant CI/CD time investment for marginal coverage benefit
5. **Overlapping Coverage**: Many integration test scenarios overlap with unit and widget tests

## Goals

- Eliminate integration testing infrastructure while maintaining code quality
- Preserve unit test and widget test coverage
- Reduce CI/CD execution time
- Simplify project maintenance
- Document the change for future reference

## Non-Goals

- Removing unit tests or widget tests
- Reducing test coverage for core functionality
- Eliminating all testing from the project

## What's Being Removed vs. Kept

### Being Removed

| Category | Items | Impact |
|----------|-------|--------|
| Integration test files | 18 Dart files in `integration_test/` | -260 test scenarios |
| Test helper utilities | 8 helper files in `integration_test/helpers/` | Test-specific utilities |
| Test runner scripts | 2 shell scripts | No automated integration test execution |
| Documentation | Multiple MD files and README sections | No integration test documentation |
| OpenSpec specs | Integration test requirements | No formal integration testing requirements |

### Being Kept

| Category | Items | Purpose |
|----------|-------|---------|
| Unit tests | 7 test files in `test/` | Business logic verification |
| Widget tests | 1 test file in `test/` | UI component verification |
| Test helpers | `test/test_helpers.dart` | Shared testing utilities |
| Certificate mocks | In `test/test_helpers.dart` | Unit test support |

## Impact Analysis

### Test Coverage Impact

| Test Type | Before | After | Notes |
|-----------|--------|-------|-------|
| Unit tests | 7 files | 7 files | Unchanged |
| Widget tests | 1 file | 1 file | Unchanged |
| Integration tests | 18 files | 0 files | Removed |
| Total test files | 26 | 8 | ~69% reduction |

### Functional Coverage

- **Core business logic**: Covered by unit tests
- **UI components**: Covered by widget tests
- **Cross-component workflows**: Manual testing via checklist
- **Platform-specific features**: Manual verification

### CI/CD Impact

- **Before**: ~8-30 minutes for integration tests
- **After**: ~1-2 minutes for unit/widget tests only
- **Improvement**: ~75-85% reduction in test execution time

## Risks and Mitigations

### Risk: Reduced End-to-End Testing

**Mitigation**: Manual testing checklist covers critical workflows. Widget tests verify UI interactions. Unit tests verify business logic.

### Risk: Regression in Complex Workflows

**Mitigation**: Manual testing before releases. Reduced scope means more focused manual verification.

### Risk: Loss of Confidence in Multi-Component Interactions

**Mitigation**: The complexity that integration tests attempted to verify is largely stable. Changes to these areas will receive focused manual testing.

## Alternatives Considered

### Option 1: Keep Integration Tests as-is
- Maintain current infrastructure
- Continue fixing flaky tests
- **Rejected**: Ongoing maintenance cost outweighs benefits

### Option 2: Migrate to E2E Testing Framework (e.g., Patrol)
- Replace integration tests with Patrol
- **Rejected**: Similar maintenance overhead, learning curve

### Option 3: Remove Integration Tests (Selected)
- Remove all integration test infrastructure
- Rely on unit tests, widget tests, and manual verification
- **Selected**: Best balance of cost vs. benefit

## Migration Path

1. **Create change proposal** (current step)
2. **Implement removal** following tasks.md checklist
3. **Verify functionality** with unit tests and manual testing
4. **Update documentation** to reflect new testing approach
5. **Archive** change proposal after implementation

## Success Criteria

- [ ] All integration test files removed
- [ ] All integration test scripts removed
- [ ] All integration test documentation removed or updated
- [ ] Unit tests pass without modifications
- [ ] Widget tests pass without modifications
- [ ] Project builds successfully
- [ ] `flutter test` executes without integration_test dependency
- [ ] OpenSpec specifications updated
- [ ] README.md updated to reflect testing strategy change
