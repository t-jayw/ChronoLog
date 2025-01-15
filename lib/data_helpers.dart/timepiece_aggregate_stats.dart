import 'package:chronolog/data_helpers.dart/format_duration.dart';
import 'package:chronolog/data_helpers.dart/timing_run_parser.dart';
import 'package:chronolog/models/timepiece.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timing_measurements_list_provider.dart';
import '../providers/timing_run_provider.dart';


class TimepieceAggregateStats {
  final Timepiece timepiece;
  final WidgetRef ref;
  late double averageSecondsPerDay;
  late Duration totalDuration;
  late int totalMeasurements;
  late int totalMilliSecondsChange;
  late int runsCount;

  TimepieceAggregateStats(this.timepiece, this.ref) {
    _calculateAggregateStats();
  }

  void _calculateAggregateStats() {
    final timingRuns = ref.read(timingRunProvider(timepiece.id));
    runsCount = timingRuns.length;
    totalMeasurements = 0;
    totalDuration = Duration();
    totalMilliSecondsChange = 0;
    double totalDays = 0;

    for (var run in timingRuns) {
      var measurements = ref.read(timingMeasurementsListProvider(run.id));
      var stats = TimingRunStatistics(measurements);
      totalMeasurements += stats.totalMeasurements;
      totalDuration += stats.totalDuration;
      totalMilliSecondsChange += stats.totalMilliSecondsChange;
      totalDays += stats.totalDuration.inSeconds / 86400;
    }

    averageSecondsPerDay = totalDays > 0 ? (totalMilliSecondsChange / 1000) / totalDays : 0;
  }

  // Formatted getters for UI display
  String get formattedTotalDuration {
    final (amount, unit) = formatDuration(totalDuration);
    return '$amount $unit';
  }
  String get formattedAverageSecondsPerDay => "${averageSecondsPerDay.toStringAsFixed(1)} sec/day";
  String get formattedTotalMeasurements => "$totalMeasurements measurements";
  String get formattedTotalMilliSecondsChange => "${(totalMilliSecondsChange / 1000).toStringAsFixed(1)} sec";
}
