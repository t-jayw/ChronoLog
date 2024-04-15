import 'package:chronolog/data_helpers.dart/format_duration.dart';
import 'package:chronolog/models/timing_measurement.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting

class TimingRunStatistics {
  final List<TimingMeasurement> measurements;
  late final double secondsPerDayForRun;
  late final Duration totalDuration;
  late final int totalMeasurements;
  late final int totalMilliSecondsChange;
  late final Duration timeSinceLastMeasurement;
  late final int totalPoints;
  late final String firstMeasurementDateTime;
  late final double latestOffsetSeconds; // Latest offset in seconds
  late final DateTime startDate;
  late final DateTime endDate;

  TimingRunStatistics(this.measurements) {
    totalMeasurements = measurements.length;
    totalDuration = _calculateTotalDuration(measurements);
    totalMilliSecondsChange = _calculateTotalMilliSecondsChange(measurements);
    secondsPerDayForRun = _calculateRatePerDay();
    timeSinceLastMeasurement = _calculateTimeSinceLastMeasurement();
    totalPoints = _calculateTotalPoints(measurements);
    firstMeasurementDateTime = _formatFirstMeasurementDateTime();
    latestOffsetSeconds = _calculateLatestOffsetSeconds();
    if (!measurements.isEmpty) {
      startDate = measurements.first
          .system_time; // Start date is the system_time of the first measurement
      endDate = measurements.last
          .system_time; // End date is the system_time of the last measurement
    } else {
      DateTime now = DateTime.now();
      startDate = now; // Fallback to current time if no measurements
      endDate = now; // Fallback to current time if no measurements
    }
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

  int _calculateTotalMilliSecondsChange(List<TimingMeasurement> measurements) {
    if (measurements.isEmpty) return 0;
    return measurements.first.difference_ms! - measurements.last.difference_ms!;
  }

  double _calculateRatePerDay() {
    if (totalDuration == Duration.zero) return 0.0;
    double totalDurationInDays = totalDuration.inSeconds / (24 * 60 * 60);
    return totalMilliSecondsChange / 1000 / totalDurationInDays;
  }

  Duration _calculateTimeSinceLastMeasurement() {
    if (measurements.isEmpty) return Duration.zero;
    return DateTime.now().difference(measurements.first.system_time);
  }

  String _formatFirstMeasurementDateTime() {
    if (measurements.isEmpty) return "No Data";
    return DateFormat('yyyy-MM-dd')
        .format(measurements.first.system_time.toLocal());
  }

  double _calculateLatestOffsetSeconds() {
    if (measurements.isEmpty) return 0.0;
    return measurements.last.difference_ms! /
        1000.0; // Convert milliseconds to seconds
  }

  // Formatting methods to expose data as string for UI or logging
  String formattedSecondsPerDayForRun() {
    return secondsPerDayForRun.isNaN
        ? '--'
        : secondsPerDayForRun.toStringAsFixed(1);
  }

  String formattedTotalDuration() => formatDuration(totalDuration);
  String formattedTimeSinceLastMeasurement() =>
      formatDuration(timeSinceLastMeasurement);
  String formattedLatestOffset() =>
      "${latestOffsetSeconds.toStringAsFixed(1)} s"; // Format the latest offset

  String formattedStartDate() {
    return DateFormat('dd MMM yyyy').format(startDate);
  }

  String formattedEndDate() {
    return DateFormat('dd MMM yyyy').format(endDate);
  }
}
