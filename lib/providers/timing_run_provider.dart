import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database_helpers.dart';
import '../models/timing_run.dart';
import 'dbHelperProvider.dart';
import '../supabase_helpers.dart';

class TimingRunProvider extends StateNotifier<List<TimingRun>> {
  final String watchId;
  final DatabaseHelper _db;
  final ProviderContainer ref; // Add ProviderReference field

  TimingRunProvider(this.watchId, this._db, this.ref) : super([]) {
    initTimingRuns();
  }

  Future<void> initTimingRuns() async {
    state = await _db.getTimingRunsByWatchId(watchId);
    state.sort((a, b) => b.id.compareTo(a.id)); // Sort the list in descending order
  }

  Future<void> addTimingRun(TimingRun timingRun) async {
    final newTimingRun = await _db.insertTimingRun(timingRun);
    state = [newTimingRun, ...state];
    state.sort((a, b) => b.id.compareTo(a.id)); // Sort in descending order

    // Sending event to Supabase
    final supabase = ref.read(supabaseManagerProvider);
    await supabase.insertEvent(timingRun, 'timing_runs_events', customEventType: 'add_run');
  }

  Future<void> deleteTimingRun(String timingRunId) async {
    await _db.deleteTimingRun(timingRunId);
    state = state.where((run) => run.id != timingRunId).toList();
    state.sort((a, b) => b.id.compareTo(a.id)); // Sort in descending order

    // Sending event to Supabase
    final supabase = ref.read(supabaseManagerProvider);
    await supabase.insertEvent({'timingRunId': timingRunId}, 'timing_runs_events', customEventType: 'delete_run');
  }
}

// SupabaseManager provider for easy access from within other providers
final supabaseManagerProvider = Provider<SupabaseManager>((ref) {
  return SupabaseManager();
});

final timingRunProvider = StateNotifierProvider.family<TimingRunProvider, List<TimingRun>, String>((ref, watchId) {
  final dbHelper = ref.watch(dbHelperProvider);
  return TimingRunProvider(watchId, dbHelper, ref.container); // Pass ref.container to TimingRunProvider
});
