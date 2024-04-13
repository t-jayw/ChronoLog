import 'package:chronolog/supabase_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import '../database_helpers.dart';
import '../models/timing_measurement.dart';
import 'dbHelperProvider.dart';


class TimingMeasurementsListProvider extends StateNotifier<List<TimingMeasurement>> {
  final String runId;
  final DatabaseHelper _db;

  TimingMeasurementsListProvider(this.runId, this._db) : super([]) {
    initTimingMeasurements();
  }

  Future<void> initTimingMeasurements() async {
    state = await _db.getTimingMeasurementsByRunId(runId);
    state.sort((a, b) => b.id.compareTo(a.id)); // Sort in descending order
  }

  Future<void> addTimingMeasurement(TimingMeasurement timingMeasurement) async {
    final newTimingMeasurement = await _db.insertTimingMeasurement(timingMeasurement);
    state = [newTimingMeasurement, ...state];

    // Capture event in Posthog
    Posthog().capture(
      eventName: 'measurement_added',
      properties: {'total_measurements': state.length},
    );

    // Insert event to Supabase
    await SupabaseManager().insertEvent(timingMeasurement, 'timing_measurements_events', customEventType: 'measurement_added');
  }

  Future<void> deleteTimingMeasurement(String timingMeasurementId) async {
    await _db.deleteTimingMeasurement(timingMeasurementId);
    state = state.where((measurement) => measurement.id != timingMeasurementId).toList();
  }

  Future<void> updateTimingMeasurement(TimingMeasurement updatedTimingMeasurement) async {
    await _db.updateTimingMeasurement(updatedTimingMeasurement);
    final index = state.indexWhere((measurement) => measurement.id == updatedTimingMeasurement.id);
    if (index != -1) {
      state[index] = updatedTimingMeasurement;
      state = List.from(state); // Notify listeners

      // Update event in Supabase
      await SupabaseManager().insertEvent(updatedTimingMeasurement, 'timing_measurements_events', customEventType: 'measurement_updated');
    }
  }
}

// StateNotifierProvider setup
final timingMeasurementsListProvider = StateNotifierProvider.family<TimingMeasurementsListProvider, List<TimingMeasurement>, String>(
    (ref, timingRunId) {
  final dbHelper = ref.watch(dbHelperProvider);
  return TimingMeasurementsListProvider(timingRunId, dbHelper);
});
