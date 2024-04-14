import 'package:chronolog/data_helpers.dart/format_duration.dart';
import 'package:chronolog/models/timing_measurement.dart';
import 'package:intl/intl.dart';  // Import intl for date formatting

class TimingRunStatistics {

  final List<TimingMeasurement> measurements;
  late final double secondsPerDayForRun;
  late final Duration totalDuration;
  late final int totalMeasurements;
  late final int totalSecondsChange;
  late final Duration timeSinceLastMeasurement;
  late final int totalPoints;
  late final String firstMeasurementDateTime;

  TimingRunStatistics(this.measurements) {
    totalMeasurements = measurements.length;
    totalDuration = _calculateTotalDuration(measurements);
    totalSecondsChange = _calculateTotalSecondsChange(measurements);
    secondsPerDayForRun = _calculateRatePerDay();
    timeSinceLastMeasurement = _calculateTimeSinceLastMeasurement();
    totalPoints = _calculateTotalPoints(measurements);
    firstMeasurementDateTime = _formatFirstMeasurementDateTime();
  }

  Duration _calculateTotalDuration(List<TimingMeasurement> measurements) {
    if (measurements.isEmpty) return Duration();
    DateTime firstDate = measurements.first.system_time;
    DateTime lastDate = measurements.last.system_time;
    return firstDate.difference(lastDate);
  }

  int _calculateTotalPoints(List<TimingMeasurement> measurements) {
    return measurements.length;
  }

  int _calculateTotalSecondsChange(List<TimingMeasurement> measurements) {
    if (measurements.isEmpty) return 0;
    return measurements.first.difference_ms! - measurements.last.difference_ms!;
  }

  double _calculateRatePerDay() {
    if (totalDuration == 0) return 0.0;
    double totalDurationInDays = totalDuration.inSeconds / (24 * 60 * 60);
    return totalSecondsChange / totalDurationInDays;
  }

  Duration _calculateTimeSinceLastMeasurement() {
    if (measurements.isEmpty) return Duration.zero;
    return DateTime.now().difference(measurements.last.system_time);
  }

  String _formatFirstMeasurementDateTime() {
    if (measurements.isEmpty) return "No Data";
    // Format the first measurement's date and time for display
    return DateFormat('yyyy-MM-dd').format(measurements.first.system_time.toLocal());
  }

  // Formatting methods to expose data as string for UI or logging
  String formattedSecondsPerDayForRun() => secondsPerDayForRun.toStringAsFixed(1);
  String formattedTotalDuration() => formatDuration(totalDuration);
  String formattedTimeSinceLastMeasurement() => formatDuration(timeSinceLastMeasurement); 
}
