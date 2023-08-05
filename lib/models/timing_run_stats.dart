class TimingRunStats {
  const TimingRunStats({
    required this.run_id,
    required this.startDate,
  });

  final String run_id;
  final DateTime startDate;
  
  TimingRunStats copyWith({
    String? id,
    String? watch_id,
    DateTime? startDate,
  }) {
    return TimingRunStats(
      run_id: id ?? run_id,
      startDate: startDate ?? this.startDate,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'run_id': run_id,
      'startDate': startDate.millisecondsSinceEpoch,
    };
  }
}
