import 'dart:async';

import 'package:csv/csv.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:chronolog/models/timing_measurement.dart';
import '../models/timepiece.dart';

import 'models/timing_run.dart';

class DatabaseHelper {
  static Future<Database>? _database;

  DatabaseHelper() {
    _initDb();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    var databasesPath = await getDatabasesPath();
    var databasePath = join(databasesPath, 'timepiece_database.db');
    print('Database Path: $databasePath');

    var db = await openDatabase(
      databasePath,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE timepieces(id TEXT PRIMARY KEY, brand TEXT, model TEXT, serial TEXT, purchaseDate INTEGER, notes TEXT, imageUrl TEXT, image BLOB)',
        );
        print('Table timepieces created');
        await db.execute(
          'CREATE TABLE timing_runs(id TEXT PRIMARY KEY, watch_id TEXT, startDate INTEGER, FOREIGN KEY (watch_id) REFERENCES timepieces(id))',
        );
        print('Table timing_runs created');
        await db.execute(
          'CREATE TABLE timing_measurements(id TEXT PRIMARY KEY, run_id TEXT, system_time INTEGER, user_input_time INTEGER, image BLOB, difference_ms INTEGER, tag TEXT,  FOREIGN KEY (run_id) REFERENCES timing_runs(id))',
        );
        print('Table timing_measurements created');
      },
      // onUpgrade: (db, oldVersion, newVersion) async {
      //   if (oldVersion < 2) {
      //     await db.execute("ALTER TABLE timepieces DROP COLUMN movementType;");
      //     await db.execute("ALTER TABLE timepieces DROP COLUMN name;");

      //   }
      // },
      version: 1, // Increment this
    );

    return db;
  }

  Future<String> getDatabaseVersion() async {
    final db = await database;
    final version = await db.getVersion();
    return version.toString();
  }

  Future<void> insertTimepiece(Timepiece timepiece) async {
    final db = await database;
    await db.insert(
      'timepieces',
      timepiece.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeTimepiece(String id) async {
    final db = await database;
    await db.delete(
      'timepieces',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<List<Timepiece>> getTimepieces() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('timepieces');

    return List.generate(maps.length, (i) {
      return Timepiece(
        id: maps[i]['id'],
        brand: maps[i]['brand'],
        model: maps[i]['model'],
        serial: maps[i]['serial'],
        purchaseDate:
            DateTime.fromMillisecondsSinceEpoch(maps[i]['purchaseDate']),
        notes: maps[i]['notes'],
        imageUrl: maps[i]['imageUrl'],
        image: maps[i]['image'],
      );
    });
  }

  Future<List<TimingRun>> getTimingRunsByWatchId(String watchId) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'timing_runs',
      where: 'watch_id = ?',
      whereArgs: [watchId],
      orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) {
      return TimingRun(
        id: maps[i]['id'],
        watch_id: maps[i]['watch_id'],
        startDate: DateTime.fromMillisecondsSinceEpoch(maps[i]['startDate']),
      );
    });
  }

  Future<TimingRun> insertTimingRun(TimingRun timingRun) async {
    final db = await database;
    final id = await db.insert(
      'timing_runs',
      timingRun.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return timingRun;
  }

  Future<void> deleteTimingRun(String timingRunId) async {
    final db = await database;
    await db.delete(
      'timing_runs',
      where: "id = ?",
      whereArgs: [timingRunId],
    );
  }

  Future<List<TimingMeasurement>> getTimingMeasurementsByRunId(
      String runId) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'timing_measurements',
      where: 'run_id = ?',
      whereArgs: [runId],
      orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) {
      return TimingMeasurement(
        id: maps[i]['id'],
        run_id: maps[i]['run_id'],
        image: maps[i]['image'],
        difference_ms: maps[i]['difference_ms'],
        tag: maps[i]['tag'],
        user_input_time:
            DateTime.fromMillisecondsSinceEpoch(maps[i]['user_input_time']),
        system_time:
            DateTime.fromMillisecondsSinceEpoch(maps[i]['system_time']),
      );
    });
  }

  Future<TimingMeasurement> insertTimingMeasurement(
      TimingMeasurement timingMeasurement) async {
    final db = await database;
    final id = await db.insert(
      'timing_measurements',
      timingMeasurement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return timingMeasurement;
  }

  Future<void> deleteTimingMeasurement(String timingMeasurementId) async {
    final db = await database;
    await db.delete(
      'timing_measurements',
      where: "id = ?",
      whereArgs: [timingMeasurementId],
    );
  }

  Future<void> updateTimepiece(Timepiece timepiece) async {
    // Assuming you're using sqflite for the database
    final db = await database;

    await db.update(
      'timepieces', // Replace 'timepieces' with your actual table name
      timepiece.toMap(),
      where: 'id = ?',
      whereArgs: [timepiece.id],
    );
  }

  Future<void> updateTimingMeasurement(
      TimingMeasurement timingMeasurement) async {
    // Assuming you're using sqflite for the database
    final db = await database;

    print('update timing measurement');
    print(timingMeasurement.id);

    await db.update(
      'timing_measurements', // Replace 'timepieces' with your actual table name
      timingMeasurement.toMap(),
      where: 'id = ?',
      whereArgs: [timingMeasurement.id],
    );
  }

  Future<String> exportDataToCsv() async {
    final List<Timepiece> timepieces = await getTimepieces();

    // Prepare data
    List<List<dynamic>> rows = [];

    // Header
    rows.add([
      'Timepiece Id', 'Brand', 'Model', 'Serial',
      'Timing Run Id', 'Watch Id', 'Start Date',
      'Timing Measurement Id', 'Run Id', 'System Time', 'Input Time', 'Difference (ms)', 'Tag',
      // More columns as needed
    ]);

    for (Timepiece timepiece in timepieces) {
          final List<TimingRun> timingRuns = await getTimingRunsByWatchId(timepiece.id); // Initialize with your data

      for (TimingRun run in timingRuns) {
            final List<TimingMeasurement> timingMeasurements = await getTimingMeasurementsByRunId(run.id); // Initialize with your data

        for (TimingMeasurement measurement in timingMeasurements) {
          rows.add([
            timepiece.id, 
            timepiece.brand, 
            timepiece.model,
            timepiece.serial,
            run.id, 
            run.watch_id, 
            run.startDate.toString(),
            measurement.id, 
            measurement.run_id, 
            measurement.system_time,
            measurement.user_input_time,
            measurement.difference_ms,
            measurement.tag,
            // More values as needed
          ]);
        }
      }
    }

    // Convert to CSV
    String csv = const ListToCsvConverter().convert(rows);

    print(csv);

    return csv;
  }
}
