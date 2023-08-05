import 'dart:typed_data';

class TimingMeasurement {
  const TimingMeasurement(
      {required this.id,
      required this.run_id,
      required this.system_time,
      this.user_input_time,
      this.image,
      this.difference_ms,
      this.tag});

  final String id;
  final String run_id;
  final DateTime system_time;
  final DateTime? user_input_time;
  final Uint8List? image; // Use Uint8List to store image bytes
  final int? difference_ms;
  final String? tag;

  TimingMeasurement copyWith({
    String? id,
    String? run_id,
    DateTime? system_time,
    DateTime? user_input_time,
    final Uint8List? image, // Use Uint8List to store image bytes
    int? difference_ms,
    String? tag,
  }) {
    return TimingMeasurement(
      id: id ?? this.id,
      run_id: run_id ?? this.run_id,
      system_time: system_time ?? this.system_time,
      user_input_time: user_input_time ?? this.user_input_time,
      image: image ?? this.image,
      difference_ms: difference_ms ?? this.difference_ms,
      tag: tag ?? this.tag,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'run_id': run_id,
      'system_time': system_time.millisecondsSinceEpoch,
      'user_input_time': user_input_time?.millisecondsSinceEpoch,
      'image': image,
      'difference_ms': difference_ms,
      'tag': tag,
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
