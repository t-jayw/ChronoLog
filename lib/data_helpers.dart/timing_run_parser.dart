import '../models/timing_measurement.dart';

int calculateTotalDuration(List<TimingMeasurement> measurements) {
  if (measurements.isEmpty) {
    return 0;
  }

  DateTime firstDate = measurements.first.system_time;
  DateTime lastDate = measurements.last.system_time;

  return firstDate.difference(lastDate).inSeconds;
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
  int totalDuration = calculateTotalDuration(measurements);
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
