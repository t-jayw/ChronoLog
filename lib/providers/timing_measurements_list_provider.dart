import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database_helpers.dart';
import '../models/timing_measurement.dart';
import 'dbHelperProvider.dart';

class TimingMeasurementsListProvider
  extends StateNotifier<List<TimingMeasurement>> {
  final String runId;
  final DatabaseHelper _db;

  TimingMeasurementsListProvider(this.runId, this._db) : super([]) {
    initTimingMeasurements();
    //print(state);
  }

  Future<void> initTimingMeasurements() async {
    state = await _db.getTimingMeasurementsByRunId(runId);
    state.sort(
        (a, b) => b.id.compareTo(a.id)); // Sort the list in descending order
    //print(state);
  }

  Future<void> addTimingMeasurement(TimingMeasurement timingMeasurement) async {
    final newTimingMeasurement =
        await _db.insertTimingMeasurement(timingMeasurement);
    state = [newTimingMeasurement, ...state];
  }

  Future<void> deleteTimingMeasurement(String timingMeasurementId) async {
    await _db.deleteTimingMeasurement(timingMeasurementId);
    state = state
        .where((measurement) => measurement.id != timingMeasurementId)
        .toList();
  }

  Future<List<TimingMeasurement>> getTimingMeasurementsByRunId(
      String runId) async {
    final List<TimingMeasurement> timingMeasurementStatsList =
        await _db.getTimingMeasurementsByRunId(runId);
    //print(timingMeasurementStatsList[1].toMap());
    return timingMeasurementStatsList;
  }
  
  Future<void> updateTimingMeasurement(TimingMeasurement updatedTimingMeasurement) async {
  await _db.updateTimingMeasurement(updatedTimingMeasurement);
  final index = state.indexWhere((measurement) => measurement.id == updatedTimingMeasurement.id);
  if (index != -1) {
    state[index] = updatedTimingMeasurement;
    state = List.from(state); // This will notify listeners about state changes
  }
}
}

final timingMeasurementsListProvider = StateNotifierProvider.family<
    TimingMeasurementsListProvider,
    List<TimingMeasurement>,
    String>((ref, timingRunId) {
  final dbHelper = ref.watch(dbHelperProvider);
  return TimingMeasurementsListProvider(timingRunId, dbHelper);
});
