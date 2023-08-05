// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:watchbox/models/timing_measurement_stats.dart';

// import '../database_helpers.dart';

// class MeasurementStatsTable extends StatelessWidget {
//   final String runId;
//   final DatabaseHelper dbHelper = DatabaseHelper();

//   MeasurementStatsTable({required this.runId});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<TimingMeasurementStats>>(
//       future: dbHelper.getTimingMeasurementStatsByRunIdView(runId),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           return SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: DataTable(
//               columns: [
//                 DataColumn(label: Text('System Time')),
//                 DataColumn(label: Text('Difference MS')),
//                 DataColumn(label: Text('Previous System Time')),
//                 DataColumn(label: Text('Previous Difference MS')),
//                 DataColumn(label: Text('Offset Change')),
//                 DataColumn(label: Text('Duration from Last Measurement')),
//                 DataColumn(label: Text('Rate of Change from Last')),
//                 DataColumn(label: Text('Total Offset per Day')),
//                 DataColumn(label: Text('Total Measurements')),
//                 DataColumn(label: Text('Total Run Duration (Days)')),
//                 DataColumn(label: Text('Total Rate of Change per Day')),
//               ],
//               rows: snapshot.data!.map<DataRow>((row) {
//                 return DataRow(
//                   cells: [
//                     DataCell(Text(row['system_time'].toString())),
//                     DataCell(Text(row['difference_ms'].toString())),
//                     DataCell(Text(row['previous_system_time'].toString())),
//                     DataCell(Text(row['previous_difference_ms'].toString())),
//                    DataCell(Text(row['offset_change_ms'].toString())),
//                     DataCell(Text(row['duration_from_last_measurement_ms'].toString())),
//                     DataCell(Text(row['rate_of_change_from_last_ms'].toString())),
//                     DataCell(Text(row['total_offset_per_day'].toString())),
//                     DataCell(Text(row['total_measurements'].toString())),
//                     DataCell(Text(row['total_run_duration_days'].toString())),
//                     DataCell(Text(row['total_rate_of_change_per_day'].toString())),
//                   ],
//                 );
//               }).toList(),
//             ),
//           );
//         } else if (snapshot.hasError) {
//           return Text('Error: ${snapshot.error}');
//         }

//         // By default, show a loading spinner.
//         return CircularProgressIndicator();
//       },
//     );
//   }
// }
