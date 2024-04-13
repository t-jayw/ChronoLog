import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:chronolog/models/timepiece.dart';
import 'package:chronolog/models/timing_run.dart';
import 'package:chronolog/models/timing_measurement.dart';

class PosthogManager {
  static final PosthogManager _singleton = PosthogManager._internal();

  factory PosthogManager() => _singleton;

  PosthogManager._internal();

  Future<void> sendEvent<T>(T item, {String? customEventType}) async {
    Map<String, dynamic> data = await _prepareData(item);
    String eventType = customEventType ?? _determineEventType<T>();

    // Send the event to PostHog
    Posthog().capture(
      eventName: eventType,
      properties: data,
    );
    print('Event $eventType sent to PostHog with data: $data');
  }

  Future<Map<String, dynamic>> _prepareData(dynamic item) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> originalData = item.toMap();

    // Converting keys to lowercase
    Map<String, dynamic> data = {
      for (var entry in originalData.entries)
        entry.key.toLowerCase(): entry.value
    };

    // Handle image processing if applicable
    if (item is Timepiece && item.image != null) {
      Uint8List compressedImage = await FlutterImageCompress.compressWithList(
        item.image!,
        minWidth: 500,
        minHeight: 500,
        quality: 90,
      );
      data['image_b64_500'] = base64Encode(compressedImage);
      data.remove('image');
    }

    return data;
  }

  String _determineEventType<T>() {
    if (T == Timepiece) return 'timepiece_event';
    if (T == TimingRun) return 'timing_run_event';
    if (T == TimingMeasurement) return 'timing_measurement_event';
    return 'undefined_event';
  }
}

// Example usage:
// final posthog = PosthogManager();
// posthog.sendEvent(timepieceObject, customEventType: 'timepiece_added');
// posthog.sendEvent(timingRunObject, customEventType: 'timing_run_created');
// posthog.sendEvent(timingMeasurementObject, customEventType: 'measurement_recorded');
