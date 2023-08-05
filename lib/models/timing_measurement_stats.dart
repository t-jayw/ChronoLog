import 'dart:typed_data';

class TimingMeasurementStats {
  const TimingMeasurementStats({
    this.id,
    this.runId,
    this.systemTime,
    this.userInputTime,
    this.image,
    this.differenceMs,
    this.previousSystemTime,
    this.previousDifferenceMs,
    this.offsetChangeMs,
    this.durationFromLastMeasurementMs,
    this.rateOfChangeFromLastMs,
    this.totalRunDurationDays,
    this.totalRateOfChangePerDay,
    this.totalMeasurements,
  });

  final String? id;
  final String? runId;
  final DateTime? systemTime;
  final Uint8List? image; // Use Uint8List to store image bytes
  final DateTime? userInputTime;
  final int? differenceMs;
  final DateTime? previousSystemTime;
  final int? previousDifferenceMs;
  final int? offsetChangeMs;
  final int? durationFromLastMeasurementMs;
  final int? rateOfChangeFromLastMs;
  final double? totalRunDurationDays;
  final int? totalRateOfChangePerDay;
  final int? totalMeasurements;

  TimingMeasurementStats copyWith({
    String? id,
    String? runId,
    DateTime? systemTime,
    DateTime? userInputTime,
    Uint8List? image,
    int? differenceMs,
    DateTime? previousSystemTime,
    int? previousDifferenceMs,
    int? offsetChangeMs,
    int? durationFromLastMeasurementMs,
    int? rateOfChangeFromLastMs,
    double? totalRunDurationDays,
    int? totalRateOfChangePerDay,
    int? totalMeasurements,
  }) {
    return TimingMeasurementStats(
      id: id ?? this.id,
      runId: runId ?? this.runId,
      systemTime: systemTime ?? this.systemTime,
      userInputTime: userInputTime ?? this.userInputTime,
      image: image ?? this.image,
      differenceMs: differenceMs ?? this.differenceMs,
      previousSystemTime: previousSystemTime ?? this.previousSystemTime,
      previousDifferenceMs: previousDifferenceMs ?? this.previousDifferenceMs,
      offsetChangeMs: offsetChangeMs ?? this.offsetChangeMs,
      durationFromLastMeasurementMs:
          durationFromLastMeasurementMs ?? this.durationFromLastMeasurementMs,
      rateOfChangeFromLastMs:
          rateOfChangeFromLastMs ?? this.rateOfChangeFromLastMs,
      totalRunDurationDays: totalRunDurationDays ?? this.totalRunDurationDays,
      totalRateOfChangePerDay:
          totalRateOfChangePerDay ?? this.totalRateOfChangePerDay,
      totalMeasurements: totalMeasurements ?? this.totalMeasurements,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'runId': runId,
      'systemTime': systemTime!.millisecondsSinceEpoch,
      'userInputTime': userInputTime?.millisecondsSinceEpoch,
      'image': image,
      'differenceMs': differenceMs,
      'previousSystemTime': previousSystemTime?.millisecondsSinceEpoch,
      'previousDifferenceMs': previousDifferenceMs,
      'offsetChangeMs': offsetChangeMs,
      'durationFromLastMeasurementMs': durationFromLastMeasurementMs,
      'rateOfChangeFromLastMs': rateOfChangeFromLastMs,
      'totalRunDurationDays': totalRunDurationDays,
      'totalRateOfChangePerDay': totalRateOfChangePerDay,
      'totalMeasurements': totalMeasurements,
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }

  double? get differenceSeconds {
    if (differenceMs != null) {
      return double.tryParse((differenceMs! / 1000).toStringAsFixed(1));
    }
    return null;
  }
}
