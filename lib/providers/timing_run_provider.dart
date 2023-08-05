import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronolog/providers/timing_measurements_list_provider.dart';

import '../database_helpers.dart';
import '../models/timing_measurement.dart';
import 'dbHelperProvider.dart';
import '../models/timing_run.dart';

class TimingRunProvider extends StateNotifier<List<TimingRun>> {
  final String watchId;
  final DatabaseHelper _db;
  final ProviderContainer ref; // Add ProviderReference field

  TimingRunProvider(this.watchId, this._db, this.ref) : super([]) {
    initTimingRuns();
  }

  Future<void> initTimingRuns() async {
    state = await _db.getTimingRunsByWatchId(watchId);
    //print(state);
    state.sort(
        (a, b) => b.id.compareTo(a.id)); // Sort the list in descending order
    //print('init state');
    //print(state);
  }

  Future<void> addTimingRun(TimingRun timingRun) async {
    final newTimingRun = await _db.insertTimingRun(timingRun);
    state = [...state, newTimingRun];
    state.sort(
        (a, b) => b.id.compareTo(a.id)); // Sort the list in descending order
  }

  Future<void> deleteTimingRun(String timingRunId) async {
    await _db.deleteTimingRun(timingRunId);
    state = state.where((run) => run.id != timingRunId).toList();
    state.sort(
        (a, b) => b.id.compareTo(a.id)); // Sort the list in descending order
  }

  TimingRun? getLatestRun() {
    return state.first; // because you're sorting in descending order
  }

  // Example implementation: assuming TimingRun has a property `differenceMs`
  // int? getLatestOffset() {
  //   final latestRun = getLatestRun();
  //   if (latestRun != null) {
  //     // assuming differenceMs is a property in TimingRun
  //     return latestRun.differenceMs;
  //   }
  //   return null;
  // }

  // Implement the following methods according to your business logic
  double getTotalChangeInSecPerDay() {
    // implement this
    return 0.0;
  }

  int getNumberOfMeasurements() {
    // implement this
    return 0;
  }
}

final timingRunProvider =
    StateNotifierProvider.family<TimingRunProvider, List<TimingRun>, String>(
        (ref, watchId) {
  final dbHelper = ref.watch(dbHelperProvider);
  return TimingRunProvider(watchId, dbHelper,
      ref.container); // Pass ref.container to TimingRunProvider
});
