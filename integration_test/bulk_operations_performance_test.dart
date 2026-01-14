import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mcal/providers/event_provider.dart';
import 'package:mcal/services/event_storage.dart';
import 'package:mcal/models/event.dart';
import 'package:mcal/frb_generated.dart';
import 'dart:developer';
import '../test/test_helpers.dart';
import 'helpers/test_fixtures.dart';

/// Comprehensive performance integration test for bulk operations
///
/// This test suite validates all bulk operation optimizations and measures
/// actual performance improvements. It includes tests for:
/// - Bulk event creation performance (<30 seconds for 100 events)
/// - Bulk event loading performance (<3 seconds for 100 events)
/// - UI responsiveness during bulk operations
/// - Background isolate processing
/// - Algorithm optimizations and caching
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await RustLib.init();
    await setupAllIntegrationMocks();
  });

  setUp(() async {
    await cleanTestEvents();
    // Clear event cache before each test
    Event.clearDateCache();
  });

  tearDownAll(() async {
    await cleanupTestEnvironment();
  });

  group('Bulk Operations Performance Tests', () {
    group('Task 1: Bulk Event Creation Performance', () {
      testWidgets('100 bulk event creation completes in under 30 seconds', (
        tester,
      ) async {
        final stopwatch = Stopwatch()..start();

        final provider = EventProvider();
        final events = TestFixtures.createLargeEventSet(count: 100);

        // Use addEventsBatch for optimal performance
        final filenames = await provider.addEventsBatch(events);

        stopwatch.stop();

        // Verify performance target
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(30000),
          reason:
              '100 bulk event creation should complete in under 30 seconds, took ${stopwatch.elapsedMilliseconds}ms',
        );

        // Verify correctness
        expect(filenames.length, equals(100));
        expect(provider.eventsCount, equals(100));

        // Log detailed performance metrics
        logPerformanceMetrics(
          '100 bulk event creation',
          stopwatch.elapsedMilliseconds,
          eventCount: 100,
        );
      });

      testWidgets('Bulk event creation with mixed recurrence types', (
        tester,
      ) async {
        final stopwatch = Stopwatch()..start();

        final provider = EventProvider();

        // Create mixed event types for realistic workload
        final events = <Event>[];
        events.addAll(TestFixtures.createLargeEventSet(count: 50));
        events.add(TestFixtures.createDailyStandup());
        events.add(TestFixtures.createWeeklyMeeting());
        events.add(TestFixtures.createMonthlyReview());
        events.add(TestFixtures.createBirthdayEvent());

        final filenames = await provider.addEventsBatch(events);

        stopwatch.stop();

        // Verify performance target (54 events total)
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(30000),
          reason:
              'Mixed recurrence bulk creation should complete in under 30 seconds, took ${stopwatch.elapsedMilliseconds}ms',
        );

        expect(filenames.length, equals(54));
        expect(provider.eventsCount, equals(54));

        logPerformanceMetrics(
          'Mixed recurrence bulk creation (54 events)',
          stopwatch.elapsedMilliseconds,
          eventCount: 54,
        );
      });

      testWidgets('Single event creation time target', (tester) async {
        final provider = EventProvider();
        final stopwatch = Stopwatch();

        // Create 10 events and measure average time per event
        for (int i = 0; i < 10; i++) {
          stopwatch.start();
          final event = Event(
            title: 'Performance Test Event $i',
            startDate: DateTime.now().add(Duration(days: i)),
            startTime: '14:00',
            endTime: '15:00',
          );
          await provider.addEvent(event);
          stopwatch.stop();
        }

        final averageTime = stopwatch.elapsedMilliseconds / 10;

        // Verify single event creation target (<500ms)
        expect(
          averageTime,
          lessThan(500),
          reason:
              'Single event creation should average under 500ms, was ${averageTime.toStringAsFixed(2)}ms',
        );

        logPerformanceMetrics(
          'Average single event creation',
          averageTime.toInt(),
          eventCount: 10,
        );
      });
    });

    group('Task 2: Bulk Event Loading Performance', () {
      testWidgets('100 event loading completes in under 3 seconds', (
        tester,
      ) async {
        // First create the events
        final createProvider = EventProvider();
        final events = TestFixtures.createLargeEventSet(count: 100);
        await createProvider.addEventsBatch(events);

        // Clear provider to simulate fresh load
        final loadProvider = EventProvider();

        final stopwatch = Stopwatch()..start();
        await loadProvider.loadAllEvents();
        stopwatch.stop();

        // Verify performance target
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(3000),
          reason:
              '100 event loading should complete in under 3 seconds, took ${stopwatch.elapsedMilliseconds}ms',
        );

        expect(loadProvider.eventsCount, equals(100));

        logPerformanceMetrics(
          '100 event loading',
          stopwatch.elapsedMilliseconds,
          eventCount: 100,
        );
      });

      testWidgets('Event loading with parallel file reading', (tester) async {
        // Create events first
        final createProvider = EventProvider();
        final events = TestFixtures.createLargeEventSet(count: 100);
        await createProvider.addEventsBatch(events);

        // Clear cache to ensure fresh load
        Event.clearDateCache();

        // Load using EventStorage directly to test parallel file reading
        final storage = EventStorage();
        final stopwatch = Stopwatch()..start();
        final loadedEvents = await storage.loadAllEvents();
        stopwatch.stop();

        // Verify parallel loading performance
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(3000),
          reason:
              'Parallel file loading should complete in under 3 seconds, took ${stopwatch.elapsedMilliseconds}ms',
        );

        expect(loadedEvents.length, equals(100));

        logPerformanceMetrics(
          'Parallel file loading (100 events)',
          stopwatch.elapsedMilliseconds,
          eventCount: 100,
        );
      });

      testWidgets('Incremental event loading performance', (tester) async {
        final provider = EventProvider();

        // Load empty state
        var stopwatch = Stopwatch()..start();
        await provider.loadAllEvents();
        stopwatch.stop();
        final emptyLoadTime = stopwatch.elapsedMilliseconds;

        // Add some events
        final events = TestFixtures.createLargeEventSet(count: 25);
        await provider.addEventsBatch(events);

        // Reload
        stopwatch = Stopwatch()..start();
        await provider.loadAllEvents();
        stopwatch.stop();
        final incrementalLoadTime = stopwatch.elapsedMilliseconds;

        // Verify incremental loading is still fast
        expect(
          incrementalLoadTime,
          lessThan(1500),
          reason:
              'Incremental event loading should be fast, took ${incrementalLoadTime}ms',
        );

        expect(provider.eventsCount, equals(25));

        logPerformanceMetrics(
          'Empty state loading',
          emptyLoadTime,
          eventCount: 0,
        );
        logPerformanceMetrics(
          'Incremental loading (25 events)',
          incrementalLoadTime,
          eventCount: 25,
        );
      });
    });

    group('Task 3: UI Responsiveness During Bulk Operations', () {
      testWidgets('UI remains responsive during bulk operations', (
        tester,
      ) async {
        final provider = EventProvider();
        final events = TestFixtures.createLargeEventSet(count: 100);

        final uiFrameTimes = <int>[];
        int frameCount = 0;

        // Monitor frame rendering times during bulk operation
        Future<void> bulkOperation() async {
          await provider.addEventsBatch(events);
        }

        // Create a widget to measure frame times
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  // Measure frames during operation
                  final binding =
                      WidgetsFlutterBinding.ensureInitialized()
                          as WidgetsFlutterBinding;
                  final originalFrameCallback =
                      binding.platformDispatcher.onReportTimings;

                  binding.platformDispatcher.onReportTimings = (timings) {
                    frameCount++;
                    for (final timing in timings) {
                      // Record frame build time (total time from frame start to raster finish)
                      final frameTime = timing.totalSpan.inMilliseconds;
                      uiFrameTimes.add(frameTime);
                    }
                    originalFrameCallback?.call(timings);
                  };

                  // Run bulk operation after first frame
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    bulkOperation();
                  });

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );

        // Wait for bulk operation to complete
        await tester.pumpAndSettle(const Duration(seconds: 45));

        // Verify UI responsiveness
        final slowFrames = uiFrameTimes
            .where((time) => time > 16)
            .length; // >16ms for 60fps

        expect(
          slowFrames,
          lessThan(10),
          reason:
              'UI should remain responsive during bulk operations. Found $slowFrames slow frames out of ${uiFrameTimes.length} total frames',
        );

        expect(provider.eventsCount, equals(100));

        logPerformanceMetrics(
          'UI responsiveness during bulk operations',
          0,
          eventCount: 100,
          additionalMetrics: {
            'total_frames': frameCount,
            'slow_frames': slowFrames,
            'slow_frame_percentage':
                '${(slowFrames / frameCount * 100).toStringAsFixed(1)}%',
          },
        );
      });

      testWidgets('UI updates are batched during bulk operations', (
        tester,
      ) async {
        final provider = EventProvider();
        int notifyCount = 0;

        // Monitor notifyListeners calls
        provider.addListener(() {
          notifyCount++;
        });

        final events = TestFixtures.createLargeEventSet(count: 50);

        // With batching, should have minimal notify calls
        await provider.addEventsBatch(events);

        // Should have at most a few notifies (batch updates), not 50+
        expect(
          notifyCount,
          lessThan(10),
          reason:
              'UI updates should be batched during bulk operations. Got $notifyCount notifies for 50 events',
        );

        expect(provider.eventsCount, equals(50));
      });
    });

    group('Task 4: Background Isolate Processing', () {
      testWidgets('Background isolate processing completes correctly', (
        tester,
      ) async {
        final events = <Event>[];
        // Add various recurring events to test background processing
        events.add(TestFixtures.createDailyStandup());
        events.add(TestFixtures.createWeeklyMeeting());
        events.add(TestFixtures.createMonthlyReview());
        events.add(TestFixtures.createBirthdayEvent());
        events.addAll(TestFixtures.createLargeEventSet(count: 20));

        // Test synchronous version
        final stopwatchSync = Stopwatch()..start();
        final datesSync = Event.getAllEventDates(events);
        stopwatchSync.stop();

        // Test asynchronous (background isolate) version
        final stopwatchAsync = Stopwatch()..start();
        final datesAsync = await Event.getAllEventDatesAsync(events);
        stopwatchAsync.stop();

        // Results should be identical
        final sortedSync = datesSync.toList()..sort();
        final sortedAsync = datesAsync.toList()..sort();

        expect(
          sortedAsync.length,
          equals(sortedSync.length),
          reason:
              'Async and sync results should have same length. Async: ${sortedAsync.length}, Sync: ${sortedSync.length}',
        );

        for (int i = 0; i < sortedSync.length; i++) {
          expect(
            sortedAsync[i].isAtSameMomentAs(sortedSync[i]),
            isTrue,
            reason: 'Dates should match at index $i',
          );
        }

        // Log performance comparison
        logPerformanceMetrics(
          'Background isolate processing (24 events)',
          stopwatchAsync.elapsedMilliseconds,
          eventCount: events.length,
          additionalMetrics: {
            'sync_time_ms': stopwatchSync.elapsedMilliseconds,
            'async_time_ms': stopwatchAsync.elapsedMilliseconds,
          },
        );
      });

      testWidgets('Background isolate fallback on error', (tester) async {
        final events = TestFixtures.createLargeEventSet(count: 50);

        // Test that async version falls back gracefully
        final dates = await Event.getAllEventDatesAsync(events);

        // Should still return correct results
        expect(dates.isNotEmpty, isTrue);
        expect(dates.length, greaterThan(0));
      });

      testWidgets('Isolate processing with complex recurring events', (
        tester,
      ) async {
        // Test with complex recurring event patterns
        final events = <Event>[];
        for (int i = 0; i < 10; i++) {
          events.add(
            Event(
              title: 'Complex Event $i',
              startDate: DateTime(2020, 1, 1), // Far in the past for yearly
              startTime: '10:00',
              endTime: '11:00',
              recurrence: ['daily', 'weekly', 'monthly', 'yearly'][i % 4],
              description: 'Complex recurring event $i',
            ),
          );
        }

        final stopwatch = Stopwatch()..start();
        final dates = await Event.getAllEventDatesAsync(events);
        stopwatch.stop();

        // Should complete in reasonable time even with far-future dates
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(5000),
          reason:
              'Complex recurring event processing should complete in under 5 seconds, took ${stopwatch.elapsedMilliseconds}ms',
        );

        expect(dates.isNotEmpty, isTrue);
      });
    });

    group('Task 5: Algorithm Optimization Validation', () {
      testWidgets('getAllEventDates optimization maintains correctness', (
        tester,
      ) async {
        final events = <Event>[];
        // Create various event types to test optimization
        events.add(TestFixtures.createSampleEvent());
        events.add(TestFixtures.createAllDayEvent());
        events.add(TestFixtures.createMultiDayEvent());
        events.add(TestFixtures.createDailyStandup());
        events.add(TestFixtures.createWeeklyMeeting());
        events.add(TestFixtures.createMonthlyReview());
        events.add(TestFixtures.createBirthdayEvent());
        events.addAll(TestFixtures.createLargeEventSet(count: 50));

        // Compare with a simple reference implementation
        Set<DateTime> getAllEventDatesOriginal(List<Event> events) {
          final dates = <DateTime>{};
          final endDate = DateTime.now().add(const Duration(days: 365));

          for (final event in events) {
            if (event.endDate != null &&
                event.endDate!.isBefore(DateTime.now())) {
              continue;
            }

            final expanded = Event.expandRecurring(event, endDate);
            for (final e in expanded) {
              dates.add(
                DateTime(e.startDate.year, e.startDate.month, e.startDate.day),
              );

              if (e.endDate != null) {
                final start = DateTime(
                  e.startDate.year,
                  e.startDate.month,
                  e.startDate.day,
                );
                final end = DateTime(
                  e.endDate!.year,
                  e.endDate!.month,
                  e.endDate!.day,
                );
                final days = end.difference(start).inDays;
                for (int i = 1; i <= days; i++) {
                  dates.add(start.add(Duration(days: i)));
                }
              }
            }
          }
          return dates;
        }

        // Get results from both methods
        final datesOriginal = getAllEventDatesOriginal(events);
        final datesOptimized = Event.getAllEventDates(events);

        // Sort for comparison
        final sortedOriginal = datesOriginal.toList()..sort();
        final sortedOptimized = datesOptimized.toList()..sort();

        // Results should be identical
        expect(
          sortedOptimized.length,
          equals(sortedOriginal.length),
          reason: 'Optimized version should produce same results as original',
        );

        for (int i = 0; i < sortedOriginal.length; i++) {
          expect(
            sortedOptimized[i].isAtSameMomentAs(sortedOriginal[i]),
            isTrue,
            reason: 'Dates should match at index $i',
          );
        }

        logPerformanceMetrics(
          'Algorithm optimization validation (57 events)',
          0,
          eventCount: events.length,
          additionalMetrics: {
            'original_date_count': sortedOriginal.length,
            'optimized_date_count': sortedOptimized.length,
          },
        );
      });

      testWidgets('Multi-day event date computation optimization', (
        tester,
      ) async {
        // Test multi-day event optimization specifically
        final events = <Event>[];
        for (int i = 0; i < 10; i++) {
          final start = DateTime.now().add(Duration(days: i));
          events.add(
            Event(
              title: 'Multi-day Event $i',
              startDate: start,
              endDate: start.add(Duration(days: i + 1)), // Variable length
              description: 'Multi-day event $i',
            ),
          );
        }

        final stopwatch = Stopwatch()..start();
        final dates = Event.getAllEventDates(events);
        stopwatch.stop();

        // Verify dates include all days in range
        for (final event in events) {
          final start = DateTime(
            event.startDate.year,
            event.startDate.month,
            event.startDate.day,
          );
          final end = DateTime(
            event.endDate!.year,
            event.endDate!.month,
            event.endDate!.day,
          );
          final days = end.difference(start).inDays;

          for (int i = 0; i <= days; i++) {
            final expectedDate = start.add(Duration(days: i));
            expect(
              dates.contains(expectedDate),
              isTrue,
              reason:
                  'Should contain date $expectedDate for event ${event.title}',
            );
          }
        }

        // Performance should be good
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(1000),
          reason:
              'Multi-day event computation should be fast, took ${stopwatch.elapsedMilliseconds}ms',
        );
      });
    });

    group('Task 6: Caching Performance', () {
      testWidgets('Date computation caching provides significant speedup', (
        tester,
      ) async {
        final events = TestFixtures.createLargeEventSet(count: 100);

        // Clear cache to ensure fresh computation
        Event.clearDateCache();

        // First call - computes
        final stopwatch1 = Stopwatch()..start();
        final dates1 = Event.getAllEventDates(events);
        stopwatch1.stop();
        final firstCallTime = stopwatch1.elapsedMilliseconds;

        // Second call - should use cache
        final stopwatch2 = Stopwatch()..start();
        final dates2 = Event.getAllEventDates(events);
        stopwatch2.stop();
        final secondCallTime = stopwatch2.elapsedMilliseconds;

        // Results should be identical
        expect(dates2.length, equals(dates1.length));

        // Second call should be significantly faster (caching works)
        expect(
          secondCallTime,
          lessThan(firstCallTime / 2),
          reason:
              'Cached call should be faster than first call. First: ${firstCallTime}ms, Second: ${secondCallTime}ms',
        );

        logPerformanceMetrics(
          'Date computation caching (100 events)',
          0,
          eventCount: 100,
          additionalMetrics: {
            'first_call_ms': firstCallTime,
            'second_call_ms': secondCallTime,
            'speedup_factor':
                '${(firstCallTime / secondCallTime).toStringAsFixed(2)}x',
          },
        );
      });

      testWidgets('Cache key generation is deterministic', (tester) async {
        final events = TestFixtures.createLargeEventSet(count: 20);

        // Clear cache
        Event.clearDateCache();

        // First call - populates cache
        final dates1 = Event.getAllEventDates(events);

        // Verify cache was populated
        expect(Event.cacheSize, equals(1));

        // Same events should use cache (same result)
        final dates2 = Event.getAllEventDates(events);
        expect(dates2.length, equals(dates1.length));

        // Different events should add to cache
        final events2 = TestFixtures.createLargeEventSet(count: 20);
        final dates3 = Event.getAllEventDates(events2);
        expect(Event.cacheSize, equals(2));

        // Results may differ due to different content
        // But both should have valid results
        expect(dates1.isNotEmpty, isTrue);
        expect(dates3.isNotEmpty, isTrue);
      });

      testWidgets('Cache size tracking works correctly', (tester) async {
        // Clear cache and check initial size
        Event.clearDateCache();
        expect(Event.cacheSize, equals(0));

        // Add some events
        final events1 = TestFixtures.createLargeEventSet(count: 10);
        Event.getAllEventDates(events1);
        expect(Event.cacheSize, equals(1));

        // Same events should use cache (no size increase)
        Event.getAllEventDates(events1);
        expect(Event.cacheSize, equals(1));

        // Different events should add to cache
        final events2 = TestFixtures.createLargeEventSet(count: 15);
        Event.getAllEventDates(events2);
        expect(Event.cacheSize, equals(2));

        // Clear cache should reset size
        Event.clearDateCache();
        expect(Event.cacheSize, equals(0));
      });

      testWidgets('Cache with explicit endDate parameter', (tester) async {
        final events = TestFixtures.createLargeEventSet(count: 50);

        // Clear cache
        Event.clearDateCache();

        // Call with default endDate (1 year)
        final dates1 = Event.getAllEventDates(events);
        expect(Event.cacheSize, equals(1));

        // Call with different endDate (should be cached separately)
        final customEndDate = DateTime.now().add(const Duration(days: 730));
        final dates2 = Event.getAllEventDates(events, endDate: customEndDate);
        expect(Event.cacheSize, equals(2));

        // Results may differ due to different end dates
        expect(dates2.length, greaterThanOrEqualTo(dates1.length));
      });
    });

    group('Task 7: Performance Metrics Summary', () {
      testWidgets('Comprehensive performance test suite summary', (
        tester,
      ) async {
        final performanceResults = <String, dynamic>{};

        // Test 1: Bulk creation performance
        final creationProvider = EventProvider();
        final creationEvents = TestFixtures.createLargeEventSet(count: 100);
        final creationStopwatch = Stopwatch()..start();
        await creationProvider.addEventsBatch(creationEvents);
        creationStopwatch.stop();
        performanceResults['bulk_creation_100'] = {
          'time_ms': creationStopwatch.elapsedMilliseconds,
          'target_ms': 30000,
          'passed': creationStopwatch.elapsedMilliseconds < 30000,
        };

        // Test 2: Bulk loading performance
        final loadProvider = EventProvider();
        final loadStopwatch = Stopwatch()..start();
        await loadProvider.loadAllEvents();
        loadStopwatch.stop();
        performanceResults['bulk_loading_100'] = {
          'time_ms': loadStopwatch.elapsedMilliseconds,
          'target_ms': 3000,
          'passed': loadStopwatch.elapsedMilliseconds < 3000,
        };

        // Test 3: Caching performance
        Event.clearDateCache();
        final cacheEvents = TestFixtures.createLargeEventSet(count: 100);
        final cacheStopwatch1 = Stopwatch()..start();
        Event.getAllEventDates(cacheEvents);
        cacheStopwatch1.stop();
        final cacheStopwatch2 = Stopwatch()..start();
        Event.getAllEventDates(cacheEvents);
        cacheStopwatch2.stop();
        performanceResults['caching'] = {
          'first_call_ms': cacheStopwatch1.elapsedMilliseconds,
          'second_call_ms': cacheStopwatch2.elapsedMilliseconds,
          'speedup':
              cacheStopwatch1.elapsedMilliseconds >
              cacheStopwatch2.elapsedMilliseconds,
          'passed':
              cacheStopwatch2.elapsedMilliseconds <
              cacheStopwatch1.elapsedMilliseconds,
        };

        // Test 4: Background processing correctness
        final bgEvents = TestFixtures.createLargeEventSet(count: 50);
        final bgDatesSync = Event.getAllEventDates(bgEvents);
        final bgDatesAsync = await Event.getAllEventDatesAsync(bgEvents);
        final bgSortedSync = bgDatesSync.toList()..sort();
        final bgSortedAsync = bgDatesAsync.toList()..sort();
        final bgCorrect =
            bgSortedSync.length == bgSortedAsync.length &&
            bgSortedSync.every(
              (d) => bgSortedAsync.any((a) => a.isAtSameMomentAs(d)),
            );
        performanceResults['background_processing'] = {
          'correct': bgCorrect,
          'passed': bgCorrect,
        };

        // Test 5: Algorithm optimization correctness
        final optEvents = <Event>[];
        optEvents.add(TestFixtures.createSampleEvent());
        optEvents.add(TestFixtures.createMultiDayEvent());
        optEvents.add(TestFixtures.createDailyStandup());
        final optDates = Event.getAllEventDates(optEvents);
        performanceResults['algorithm_optimization'] = {
          'dates_count': optDates.length,
          'passed': optDates.isNotEmpty,
        };

        // Print summary
        log('=== Performance Test Summary ===');
        for (final entry in performanceResults.entries) {
          log('${entry.key}: ${entry.value}');
        }

        // Verify all tests passed
        final allPassed = performanceResults.values.every(
          (result) => result['passed'] == true,
        );
        expect(
          allPassed,
          isTrue,
          reason:
              'All performance tests should pass. Results: $performanceResults',
        );
      });
    });
  });
}

/// Logs performance metrics with consistent formatting
void logPerformanceMetrics(
  String testName,
  int elapsedMs, {
  required int eventCount,
  Map<String, dynamic>? additionalMetrics,
}) {
  final buffer = StringBuffer();
  buffer.write('[$testName] ');
  buffer.write('Events: $eventCount, ');
  buffer.write('Time: ${elapsedMs}ms');

  if (additionalMetrics != null) {
    buffer.write(', ');
    buffer.write(
      additionalMetrics.entries.map((e) => '${e.key}: ${e.value}').join(', '),
    );
  }

  log(buffer.toString());
}
