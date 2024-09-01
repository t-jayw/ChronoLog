import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:ulid/ulid.dart';
import 'package:chronolog/models/timepiece.dart';
import 'package:chronolog/models/timing_run.dart';
import 'package:chronolog/models/timing_measurement.dart';

class SupabaseManager {
  static final SupabaseManager _singleton = SupabaseManager._internal();
  late final SupabaseClient _client;

  factory SupabaseManager() => _singleton;

  SupabaseManager._internal() {
    final String supabaseUrl = dotenv.env['SUPABASE_URL']!;
    final String supabaseKey = dotenv.env['SUPABASE_KEY']!;
    _client = SupabaseClient(supabaseUrl, supabaseKey);
  }

  Future<void> init() async => await dotenv.load();

  Future<void> insertEvent<T>(T item, String tableName,
      {String? customEventType}) async {
    Map<String, dynamic> data = await _prepareData(item);
    data['event_id'] = Ulid().toString();
    data['event_type'] = customEventType ?? _determineEventType<T>();
    //data['metadata'] = await _fetchMetadata();  // Collect metadata

    final response = await _client.from(tableName).insert(data);

    if (response != null) {
      if (response.error != null) {
        print('Error inserting data: ${response.error!.message}');
        throw Exception('Failed to insert data: ${response.error!.message}');
      } else {
        print(response.toString());
      }
    } else {
      print('No response -- probably good');
    }
  }

  Future<Map<String, dynamic>> _prepareData(dynamic item) async {
    final prefs = await SharedPreferences.getInstance();

    // Getting the original data from the item
    Map<String, dynamic> originalData = item.toMap();

    // Creating a new map with all keys converted to lowercase
    Map<String, dynamic> data = {
      for (var entry in originalData.entries)
        entry.key.toLowerCase(): entry.value
    };

    // Handle image compression and conversion to base64 if applicable
    // if (item is Timepiece && item.image != null) {
    //   Uint8List compressedImage = await FlutterImageCompress.compressWithList(
    //     item.image!,
    //     minWidth: 500,
    //     minHeight: 500,
    //     quality: 90,
    //   );
    //   data['image_b64_500'] = base64Encode(compressedImage);
    // }

    // Not worth handling the images in the database right now.
    // if I want in the future, will use s3 for storage.

    // Remove image data from Timepiece objects
    if (item is Timepiece) {
      data.remove('image');
      data.remove('image_b64_500');
    }

    // Remove image data from TimingMeasurement objects
    if (item is TimingMeasurement) {
      data.remove('image');
    }

    // Adding user_id if the item is a Timepiece
    if (item is Timepiece) {
      data['user_id'] = prefs.getString('userId');
      data.remove('image'); // Ensure the original image field is removed
    }

    // Adding a received timestamp
    data['received_at'] = DateTime.now().toIso8601String();

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
// final supabase = SupabaseManager();
// supabase.init().then((_) {
//   supabase.insertEvent(timepieceObject, 'timepieces_events');
//   supabase.insertEvent(timingRunObject, 'timing_runs_events');
//   supabase.insertEvent(timingMeasurementObject, 'timing_measurements_events');
// });
