## REMOVED Requirements

### Requirement: The application SHALL Linux Integration Test Runner Script

**Reason**: The entire integration test runner infrastructure is being removed from the project. The Linux integration test runner script `scripts/test-integration-linux.sh` is being deleted.

**Migration**: No replacement. Unit tests and widget tests are run via `fvm flutter test` without the need for special runner scripts.

---

### Requirement: The application SHALL Android Integration Test Runner Script

**Reason**: The entire integration test runner infrastructure is being removed from the project. The Android integration test runner script `scripts/test-integration-android.sh` is being deleted.

**Migration**: No replacement. Unit tests and widget tests are run via `fvm flutter test` without the need for special runner scripts.

---

### Requirement: The application SHALL Test Runner Performance Standards

**Reason**: This entire requirement is being removed as it references integration test runner performance standards which are no longer applicable after removing the integration test infrastructure.

**Migration**: Unit tests and widget tests execute significantly faster (under 2 minutes) compared to integration tests (5-30 minutes), eliminating the need for performance standards.

---

### Requirement: The application SHALL Test Runner Error Messages

**Reason**: This entire requirement is being removed as it references integration test runner error messages which are no longer applicable after removing the integration test infrastructure.

**Migration**: Standard Flutter test error messages are used for unit and widget test failures.

---

### Requirement: The application SHALL Test Runner Maintenance

**Reason**: This entire requirement is being removed as it references integration test runner maintenance which is no longer applicable after removing the integration test infrastructure.

**Migration**: No test runner maintenance required. Standard Flutter test command is used.

---

### Requirement: The application SHALL Makefile Integration Test Targets

**Reason**: This entire requirement is being removed as it references Makefile targets for integration test runners which are being deleted.

**Migration**: Makefile targets for unit tests and widget tests (if any) remain. Integration test Makefile targets are removed.

---

### Requirement: The application SHALL Document Integration Test Runner

**Reason**: This entire requirement is being removed as it references documentation for integration test runner which is being deleted.

**Migration**: Testing documentation in README.md is updated to reflect the new testing strategy (unit tests and widget tests only).
