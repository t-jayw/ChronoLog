class TimingRun {
  const TimingRun({
    required this.id,
    required this.watchId,
    required this.startDate,
  });

  final String id;
  final String watchId;
  final DateTime startDate;
  
  TimingRun copyWith({
    String? id,
    String? watchId,
    DateTime? startDate,
  }) {
    return TimingRun(
      id: id ?? this.id,
      watchId: watchId ?? this.watchId,
      startDate: startDate ?? this.startDate,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'watch_id': watchId,
      'startDate': startDate.millisecondsSinceEpoch,
    };
  }
}
