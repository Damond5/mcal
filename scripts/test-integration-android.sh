#!/usr/bin/env bash

# Android Integration Test Runner
#
# This script executes each integration test file individually on Android,
# working around Flutter desktop bug #101031 by ensuring clean
# app lifecycle management per test file.
#
# Note: APK caching is not supported by Flutter's integration test framework.
# APK will be rebuilt for each test file, which is slower but reliable.
#
# Usage: ./scripts/test-integration-android.sh
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
TIMEOUT_SECONDS=600  # 10 minutes max per test file
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
TOTAL_TIME=0

echo -e "${GREEN}=== Android Integration Test Runner ===${NC}"
echo ""

# Check for Flutter installation
if ! command -v fvm &> /dev/null 2>&1; then
    echo -e "${RED}Error: Flutter (fvm) is not installed${NC}"
    echo "Please install Flutter and add to PATH, or use flutter command directly"
    exit 1
fi

# Check for connected Android device
device_id=$(fvm flutter devices 2>/dev/null | grep -m 1 "android" | awk '{print $2}')

if [ -z "$device_id" ]; then
    echo -e "${RED}Error: No Android device found${NC}"
    echo ""
    echo "Available devices:"
    fvm flutter devices 2>/dev/null || true
    echo ""
    echo "Troubleshooting:"
    echo "  - Ensure Android device is connected via USB"
    echo "  - Enable USB debugging on Android device"
    echo "  - Run 'fvm flutter devices' to verify device is listed"
    exit 1
fi

echo -e "${GREEN}Using Android device: $device_id${NC}"
echo ""

# Check if integration_test directory exists
if [ ! -d "$INTEGRATION_TEST_DIR" ]; then
    echo -e "${RED}Error: Integration test directory '$INTEGRATION_TEST_DIR' not found${NC}"
    echo "Please run this script from project root directory"
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

    # Extract just filename for display
    filename=$(basename "$test_file")
    
    echo -e "${YELLOW}[$TOTAL_TESTS] Running: $filename${NC}"
    start_time=$(date +%s)

    # Run test
    if fvm flutter test "$test_file" -d "$device_id"; then
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
echo -e "Total test files: $TOTAL_TESTS"
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
