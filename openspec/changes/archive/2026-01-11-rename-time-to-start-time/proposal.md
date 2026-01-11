# Change: Rename "Time" Field to "Start Time" for rcal Format Alignment

## Why
MCAL currently uses `- **Time**: ` in its Markdown event format serialization, while the rcal reference format specifies `- **Start Time**: `. This inconsistency prevents proper interoperability between MCAL and rcal, and creates confusion about the semantic meaning of the field. Renaming the Markdown field label from `- **Time**: ` to `- **Start Time**: ` will align with rcal specification and improve semantic clarity.

## What Changes
- Rename Markdown field label from `- **Time**: ` to `- **Start Time**: ` in Event model serialization and parsing
- Update unit tests to expect the new "Start Time" field format
- Update integration tests to use the new field format  
- Update specification documentation to use "Start Time" terminology
- No changes to UI labels (already correctly show "Start Time" and "End Time")
- No changes to Event model internal field names (startTime, endTime remain unchanged)

## Impact
- **Affected specs:** event-management
- **Affected code:**
  - `lib/models/event.dart` (line 123: parsing, line 220: serialization)
  - `test/event_provider_test.dart` (lines 36, 66, 163: test expectations)
  - `integration_test/edge_cases_integration_test.dart` (lines 811, 827, 845: test data)
- **Affected documentation:**
  - `openspec/specs/event-management/spec.md`
- **BREAKING**: Existing event files with old format will need migration or backward compatibility
- **Backward compatibility:** Implement dual parsing (support both old and new formats temporarily)

## Dependencies
- None

## Risks
- Minimal - primarily renaming and documentation updates
