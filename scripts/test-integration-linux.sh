#!/usr/bin/env bash

# Linux Integration Test Runner
#
# This script works around Flutter desktop bug #101031 by executing
# each integration test file individually, ensuring clean app lifecycle
# management per test file.
#
# Usage: ./scripts/test-integration-linux.sh
#
# References:
# - Flutter Issue #101031: https://github.com/flutter/flutter/issues/101031
# - Fix plan: INTEGRATION_TEST_FIX_PLAN.md

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test configuration
INTEGRATION_TEST_DIR="integration_test"
TIMEOUT_SECONDS=300  #5 minutes per test file max
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
TOTAL_TIME=0

# Signal handler for clean interruption
cleanup() {
    echo ""
    echo -e "${YELLOW}Test run interrupted${NC}"
    exit 130
}
trap cleanup SIGINT SIGTERM

echo -e "${GREEN}=== Linux Integration Test Runner ===${NC}"
echo ""

# Check for Flutter installation
if ! command -v fvm &> /dev/null 2>&1; then
    echo -e "${RED}Error: Flutter (fvm) is not installed${NC}"
    echo "Please install Flutter and add to PATH, or use the flutter command directly"
    exit 1
fi

# Check if integration_test directory exists
if [ ! -d "$INTEGRATION_TEST_DIR" ]; then
    echo -e "${RED}Error: Integration test directory '$INTEGRATION_TEST_DIR' not found${NC}"
    echo "Please run this script from the project root directory"
    exit 1
fi

# Find all integration test files
echo "Discovering integration test files..."
TEST_FILES=($(find "$INTEGRATION_TEST_DIR" -name "*_integration_test.dart" | sort))

if [ ${#TEST_FILES[@]} -eq 0 ]; then
    echo -e "${RED}Error: No integration test files found in '$INTEGRATION_TEST_DIR'${NC}"
    exit 1
fi

echo -e "${GREEN}Found ${#TEST_FILES[@]} integration test files${NC}"
echo ""

# Run each test file individually
for test_file in "${TEST_FILES[@]}"; do
    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    # Extract just the filename for display
    filename=$(basename "$test_file")
    
    echo -e "${YELLOW}[$TOTAL_TESTS] Running: $filename${NC}"
    start_time=$(date +%s)

    # Run test with timeout
    if timeout "$TIMEOUT_SECONDS" fvm flutter test "$test_file" -d linux; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        exit_code=0
        status="${GREEN}PASSED${NC}"
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        exit_code=1
        status="${RED}FAILED${NC}"
    fi

    end_time=$(date +%s)
    duration=$((end_time - start_time))

    echo -e "$status: $filename (${duration}s)"

    TOTAL_TIME=$((TOTAL_TIME + duration))
done

# Print summary
echo ""
echo -e "${GREEN}=== Test Summary ===${NC}"
echo ""
echo -e "Total test files:  $TOTAL_TESTS"
echo -e "Passed:          ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed:          ${RED}$FAILED_TESTS${NC}"
echo ""
echo -e "Total execution time: ${TOTAL_TIME}s ($((TOTAL_TIME / 60)) minutes)"
echo ""

# Exit with appropriate code
if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${RED}Some tests failed${NC}"
    exit 1
else
    echo -e "${GREEN}All tests passed${NC}"
    exit 0
fi
