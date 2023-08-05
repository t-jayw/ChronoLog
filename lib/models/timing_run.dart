class TimingRun {
  const TimingRun({
    required this.id,
    required this.watch_id,
    required this.startDate,
  });

  final String id;
  final String watch_id;
  final DateTime startDate;
  
  TimingRun copyWith({
    String? id,
    String? watch_id,
    DateTime? startDate,
  }) {
    return TimingRun(
      id: id ?? this.id,
      watch_id: watch_id ?? this.watch_id,
      startDate: startDate ?? this.startDate,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'watch_id': watch_id,
      'startDate': startDate.millisecondsSinceEpoch,
    };
  }
}
