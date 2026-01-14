## Context
The MCAL application has severe performance issues with bulk operations:
- 100 event load: ~30 seconds
- 100 event creation: ~290 seconds
- UI unresponsive during bulk operations
- No progress feedback during operations

Performance analysis identified three main bottlenecks:
1. Synchronous sequential file I/O in EventStorage
2. O(n²) algorithm in date computation
3. Lack of batch operation support causing excessive UI notifications

## Goals / Non-Goals

### Goals
- Reduce 100 event creation time from 290 seconds to under 30 seconds (10x improvement)
- Reduce 100 event load time from 30 seconds to under 3 seconds (10x improvement)
- Maintain UI responsiveness during bulk operations
- Provide progress feedback during long-running operations
- Maintain backward compatibility with existing APIs

### Non-Goals
- Change the underlying event storage format (Markdown files)
- Modify the event data model structure
- Add cloud sync features
- Implement real-time collaboration

## Decisions

### Decision 1: Parallel File I/O using Future.wait()
**Chosen approach:** Use `Future.wait()` for parallel file reading in `loadAllEvents()`

**Rationale:**
- Native Dart feature, no additional dependencies
- Simple implementation with significant performance gains
- Maintains existing error handling patterns
- Risk is low - purely optimization, no API changes

**Alternatives considered:**
- Use isolates for file I/O: Overkill for this use case, adds complexity
- Use streams: More complex to implement correctly
- Use a thread pool: Not available in Dart

### Decision 2: Batch Operations with Deferred Notifications
**Chosen approach:** Add new batch methods with internal deferred notification system

**Rationale:**
- Provides clean API for bulk operations
- Maintains backward compatibility
- Allows fine-grained control over update behavior
- Can be extended for undo/redo functionality

**Implementation:**
- `pauseUpdates()`: Pause notifications and UI updates
- `resumeUpdates()`: Resume and trigger single batched notification
- `addEvents()`: Add events with deferred notifications
- `updateEvents()`: Update events with deferred notifications
- `deleteEvents()`: Delete events with deferred notifications

### Decision 3: Background Processing with compute()
**Chosen approach:** Use `compute()` for CPU-intensive date calculations

**Rationale:**
- Native Flutter/Dart feature
- Automatic isolate management
- Simple API for common use cases
- Good balance of implementation complexity and performance

**Alternatives considered:**
- Custom isolate management: More complex, same benefits
- Web Workers: Not available in Flutter
- Async/Await with `Isolate.spawn()`: More verbose than compute()

### Decision 4: Algorithm Optimization for getAllEventDates()
**Chosen approach:** Implement linear-time algorithm with result caching

**Rationale:**
- Current O(n²) algorithm is the root cause of exponential time growth
- Linear algorithm is straightforward to implement
- Caching provides additional performance for repeated calls
- No breaking changes to API

**Implementation:**
- Convert from nested iteration to single-pass date collection
- Use Set for O(1) duplicate detection
- Cache results with EventProvider as the cache owner
- Invalidate cache on event changes

## Risks / Trade-offs

| Risk | Impact | Mitigation |
|------|--------|------------|
| Race conditions in parallel I/O | Medium | Add proper error handling for partial failures |
| Memory usage with batch operations | Low | Add size limits to batch operations |
| Isolate communication overhead | Low | Use compute() only for CPU-intensive operations |
| Breaking existing APIs | Low | New methods only, existing APIs unchanged |

## Migration Plan

### Backward Compatibility
- All existing public APIs remain unchanged
- New batch methods are additive
- Existing unit tests should continue to pass
- No migration path needed for existing code

### Rollback Strategy
- Feature flags can disable parallel I/O
- Batch operations can be disabled via configuration
- Previous algorithm can be used as fallback if issues arise

## Open Questions
1. Should we add a maximum batch size limit? (Recommend: yes, 1000 events)
2. Should progress callbacks be required or optional? (Recommend: optional)
3. Should we add undo support for batch operations? (Recommend: future enhancement)
