import 'package:chronolog/data_helpers.dart/format_duration.dart';

import '../models/timing_measurement.dart';
import 'package:chronolog/models/timing_run.dart';

/// Calculates various statistics for a given timing run and its measurements.
Map<String, dynamic> calculateRunStatistics(
    TimingRun run, List<TimingMeasurement> measurements) {
  if (measurements.isEmpty) {
    return {
      'secondsPerDayForRun': '--',
      'totalDurationDays': '-- days',
      'totalMeasurements': 0,
      'timeSinceLastMeasurement': 'No data',
    };
  }

  // Calculate total duration in days
  String totalDurationDays =
      formatDuration(calculateTotalDuration(measurements));

  // Calculate rate per day
  double secondsPerDayForRun = calculateRatePerDay(measurements);

  // Determine the time since the last measurement
  String timeSinceLastMeasurement =
      formatDuration(DateTime.now().difference(measurements.first.system_time));

  return {
    'secondsPerDayForRun': secondsPerDayForRun.toStringAsFixed(1),
    'totalDurationDays': totalDurationDays,
    'totalMeasurements': measurements.length,
    'timeSinceLastMeasurement': timeSinceLastMeasurement,
  };
}

Duration calculateTotalDuration(List<TimingMeasurement> measurements) {
  if (measurements.isEmpty) {
    return Duration();
  }

  DateTime firstDate = measurements.first.system_time;
  DateTime lastDate = measurements.last.system_time;

  return firstDate.difference(lastDate);
}

int calculateTotalSecondsChange(List<TimingMeasurement> measurements) {
  if (measurements.isEmpty) {
    return 0;
  }

  int totalChange =
      measurements.first.difference_ms! - measurements.last.difference_ms!;

  return totalChange ~/ 1000;
}

double calculateRatePerDay(List<TimingMeasurement> measurements) {
  int totalDuration = calculateTotalDuration(measurements).inSeconds;
  int totalSecondsChange = calculateTotalSecondsChange(measurements);

  if (totalDuration == 0) {
    return 0;
  }

  // convert total duration from seconds to days
  double totalDurationInDays = totalDuration / (24 * 60 * 60);

  // calculate rate of change per day
  double ratePerDay = totalSecondsChange / totalDurationInDays;

  return ratePerDay;
}
