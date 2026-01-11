## Context

### Background
MCAL is a calendar application that stores events as Markdown files following the rcal specification format. The rcal specification defines a standard format for event serialization that includes fields like Date, Start Time, End Time, Description, and Recurrence.

However, MCAL's current implementation uses `- **Time**: ` as the field label instead of the rcal-specified `- **Start Time**: `. This discrepancy:
1. Breaks interoperability with rcal-compatible tools
2. Creates semantic confusion about the field's purpose
3. May cause issues when migrating between calendar systems
4. Doesn't align with the existing UI that correctly shows "Start Time" and "End Time" labels

### Current Implementation Analysis
Looking at `lib/models/event.dart`:
- Line 123: Parsing checks for `- **Time**: ` prefix
- Line 220: Serialization outputs `- **Time**: ` label
- Internal field names are already correctly named `startTime` and `endTime`
- UI labels already use "Start Time" and "End Time" terminology

### Affected Files
1. `lib/models/event.dart` - Core event model (parsing at line 123, serialization at line 220)
2. `test/event_provider_test.dart` - Unit tests (lines 36, 66, 163)
3. `integration_test/edge_cases_integration_test.dart` - Integration tests (lines 811, 827, 845)
4. `openspec/specs/event-management/spec.md` - Specification documentation (line 7)

## Goals / Non-Goals

### Goals
- Rename Markdown field label from `- **Time**: ` to `- **Start Time**: ` for rcal alignment
- Maintain backward compatibility with existing event files during transition
- Update all test expectations to match new format
- Update specification documentation to reflect the change
- Improve semantic clarity of the field label

### Non-Goals
- Change internal Event model field names (startTime, endTime remain unchanged)
- Change UI labels (already correctly show "Start Time" and "End Time")
- Create a migration tool for existing event files (dual parsing handles this)
- Modify other field labels (Date, Description, Recurrence remain unchanged)
- Add new functionality or features

## Decisions

### Decision 1: Implement Dual Parsing for Backward Compatibility
**What**: Modify the parsing logic to accept both `- **Time**: ` and `- **Start Time**: ` formats during a transition period.

**Why**: 
- Existing event files using the old format will continue to work
- Users can migrate files at their own pace
- Reduces risk of data loss during transition
- Allows gradual migration of existing events

**Implementation**:
```dart
// In Event.fromMarkdown factory
if (trimmed.startsWith('- **Start Time**: ')) {
  // New format
  final timeStr = trimmed.substring(17).trim();
  // ... process timeStr
} else if (trimmed.startsWith('- **Time**: ')) {
  // Old format - for backward compatibility
  final timeStr = trimmed.substring(11).trim();
  // ... process timeStr
  // Log warning about deprecated format
}
```

### Decision 2: Always Serialize to New Format
**What**: The `toMarkdown()` method will always output `- **Start Time**: ` format.

**Why**:
- New events will use the correct format
- Over time, old format files will be naturally replaced
- Clear direction for future development
- Aligns with rcal specification

**Implementation**: Update line 220 in event.dart to use `- **Start Time**: ` label.

### Decision 3: Update Tests to New Format
**What**: Update all test files to use the new `- **Start Time**: ` format in expected outputs.

**Why**:
- Tests should validate the new behavior
- Prevents regression to old format
- Documents the expected format for future maintenance

**Implementation**: Update test expectations in:
- `test/event_provider_test.dart` (lines 36, 66, 163)
- `integration_test/edge_cases_integration_test.dart` (lines 811, 827, 845)

### Decision 4: Update Specification Documentation
**What**: Update the event-management specification to reference "Start Time" instead of "Time".

**Why**:
- Specification should reflect actual implementation
- Provides clear documentation for developers
- Aligns with rcal specification

**Implementation**: Update line 7 in `openspec/specs/event-management/spec.md`.

### Decision 5: End Time Field Documentation
- **Status**: Added
- **Rationale**: The rcal specification and existing implementation support event end times, but the current spec documentation only listed "Time" without distinguishing start/end times. This change updates the spec to match actual implementation behavior, documenting both Start Time and End Time fields explicitly.
- **Impact**: No code changes required (implementation already supports endTime). This is purely a documentation update to align spec with reality.
- **Breaking**: No - existing event files continue to work unchanged. This only affects how the specification is documented.

## Risks / Trade-offs

### Risk 1: Legacy File Interoperability
**Risk**: Users with existing event files in the old format may have compatibility issues with rcal-compatible tools.

**Mitigation**: 
- Dual parsing ensures MCAL can read old files
- New files use correct format for rcal compatibility
- Documentation should inform users about the change

**Trade-off**: Maintaining dual parsing adds minor complexity but provides better user experience.

### Risk 2: Test Maintenance
**Risk**: Updating tests may miss some edge cases or create inconsistencies.

**Mitigation**:
- Comprehensive review of all test files
- Validation run to ensure all tests pass
- Manual verification of sample outputs

**Trade-off**: Minor increase in test maintenance burden for improved accuracy.

### Risk 3: Developer Confusion
**Risk**: Developers may be confused about which format to use in new code.

**Mitigation**:
- Clear documentation in code comments
- Specification updates
- Consistent testing expectations

**Trade-off**: Brief learning curve for improved long-term clarity.

## Migration Plan

### Phase 1: Preparation (Day 1)
1. Create change proposal and get approval
2. Review all affected files and test cases
3. Prepare updated code changes
4. Document the change for users

### Phase 2: Implementation (Day 2)
1. Update `lib/models/event.dart`:
   - Modify parsing logic to support both formats
   - Update serialization to use new format
   - Add deprecation warning for old format
2. Update unit tests in `test/event_provider_test.dart`
3. Update integration tests in `integration_test/edge_cases_integration_test.dart`
4. Update specification documentation

### Phase 3: Validation (Day 3)
1. Run all unit tests to verify changes
2. Run integration tests to verify functionality
3. Run `openspec validate rename-time-to-start-time --strict`
4. Manual testing of event creation and parsing
5. Verify backward compatibility with old format files

### Phase 4: Deployment (Day 4)
1. Deploy changes to all platforms
2. Update user documentation if needed
3. Monitor for any issues
4. Archive the change proposal

### Rollback Plan
If issues are discovered after deployment:
1. Revert changes to `lib/models/event.dart` parsing logic
2. Restore old format in serialization temporarily
3. Update tests to match
4. Create patch release with fixes
5. Update change proposal with lessons learned

## Open Questions

### Q1: Should we add a migration utility?
**Question**: Should we provide a tool for users to migrate existing event files from old format to new format?

**Recommendation**: No, not in this change. Dual parsing handles the transition automatically, and adding a migration utility adds unnecessary complexity. Users can manually update files if needed.

### Q2: How long should we maintain dual parsing?
**Question**: Should we set a timeline for removing support for the old format?

**Recommendation**: Maintain dual parsing for at least 6 months (1-2 major releases) to give users time to migrate. After that, consider removing old format support based on user feedback and usage patterns.

### Q3: Should we log warnings when parsing old format?
**Question**: Should we add logging when old format files are parsed to track usage?

**Recommendation**: Yes, add an info-level log when old format is detected. This helps:
- Track how many users still have old format files
- Identify files that need migration
- Provide better debugging information

## Implementation Details

### Code Changes Required

#### lib/models/event.dart
**Line 123-132** (parsing logic):
```dart
// Old format (for backward compatibility)
} else if (trimmed.startsWith('- **Time**: ')) {
  final timeStr = trimmed.substring(11).trim();
  if (timeStr == 'all-day') {
    startTime = null;
    endTime = null;
  } else {
    final parts = timeStr.split(' to ');
    startTime = parts[0];
    if (parts.length > 1) endTime = parts[1];
  }
// New format
} else if (trimmed.startsWith('- **Start Time**: ')) {
  final timeStr = trimmed.substring(17).trim();
  if (timeStr == 'all-day') {
    startTime = null;
    endTime = null;
  } else {
    final parts = timeStr.split(' to ');
    startTime = parts[0];
    if (parts.length > 1) endTime = parts[1];
  }
```

**Line 220** (serialization):
```dart
// Update from:
- **Time**: $timeStr
// To:
- **Start Time**: $timeStr
```

#### test/event_provider_test.dart
**Lines 36, 66, 163**: Update expected markdown format from `- **Time**: ` to `- **Start Time**: `

#### integration_test/edge_cases_integration_test.dart
**Lines 811, 827, 845**: Update test event data from `- **Time**: ` to `- **Start Time**: `

#### openspec/specs/event-management/spec.md
**Line 7**: Update reference from "Time" to "Start Time" in the specification.

### Testing Strategy

#### Unit Tests
- Update test expectations to match new format
- Verify dual parsing works for both formats
- Test edge cases (all-day events, time ranges)

#### Integration Tests
- Update integration test event data
- Verify end-to-end event management workflows
- Test backward compatibility with old format files

#### Manual Testing
- Create sample events and verify markdown output
- Parse existing events to verify compatibility
- Test with rcal-compatible tools if available

## Success Criteria

1. All unit tests pass with updated format
2. All integration tests pass with updated format
3. Backward compatibility maintained for old format files
4. Specification documentation updated
5. `openspec validate rename-time-to-start-time --strict` passes
6. Code review completed with no major issues
7. User-facing documentation updated if needed

## Timeline

- **Day 1**: Create and validate change proposal
- **Day 2**: Implement code changes and update tests
- **Day 3**: Run validation and testing
- **Day 4**: Deploy and monitor

Total effort: ~1-2 days of development work
