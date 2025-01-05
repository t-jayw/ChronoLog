import 'package:chronolog/components/graphs/offset_custom_line_chart.dart';
import 'package:chronolog/data_helpers.dart/linear_regression.dart';
import 'package:chronolog/models/timing_measurement.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class CustomLineChart extends StatelessWidget {
  final List<TimingMeasurement> measurements;
  final Color lineColor;
  final String? titleText;
  final String chartType;

  const CustomLineChart({
    Key? key,
    required this.measurements,
    this.lineColor = Colors.orangeAccent,
    this.titleText,
    this.chartType = 'offset',
  }) : super(key: key);

  List<TaggedFlSpot> createOffsetDataPoints(
      List<TimingMeasurement> measurements) {
    return measurements.map((measurement) {
      final systemTime =
          measurement.system_time.millisecondsSinceEpoch.toDouble();
      final offset = measurement.difference_ms!.toDouble() / 1000;
      final tag = measurement.tag ?? 'No Tag';

      return TaggedFlSpot(systemTime, offset, tag);
    }).toList();
  }

  List<TaggedFlSpot> createRateDataPoints(
      List<TimingMeasurement> measurements) {
    List<TaggedFlSpot> data = List.generate(measurements.length - 1, (i) {
      final currentMeasurement = measurements[i];
      final nextMeasurement = measurements[i + 1];

      final currentSystemTime =
          currentMeasurement.system_time.millisecondsSinceEpoch.toDouble();
      final currentOffset = currentMeasurement.difference_ms!.toDouble() / 1000;

      final nextSystemTime =
          nextMeasurement.system_time.millisecondsSinceEpoch.toDouble();
      final nextOffset = nextMeasurement.difference_ms!.toDouble() / 1000;

      final timeDifference = (nextSystemTime - currentSystemTime) /
          1000 /
          60 /
          60 /
          24; // Time difference in days
      final rateOfChange = (nextOffset - currentOffset) /
          timeDifference; // Rate of change per day

      final tag = currentMeasurement.tag ?? 'No Tag';

      return TaggedFlSpot(currentSystemTime, rateOfChange, tag);
    });

    // Optionally, add a final spot with zero change or just end the data list
    // final lastMeasurement = timingMeasurements.last;
    // final lastSystemTime =
    //     lastMeasurement.system_time.millisecondsSinceEpoch.toDouble();
    // data.add(TaggedFlSpot(lastSystemTime, 0, lastMeasurement.tag ?? 'No Tag'));

    return data; // Remove the first element
  }

  @override
  Widget build(BuildContext context) {
    if (measurements.isEmpty) {
      // Handle empty measurements case first
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "No measurements available.\nPlease add measurements.",
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      );
    }

    List<TaggedFlSpot> offsetSpots = createOffsetDataPoints(measurements);
    List<TaggedFlSpot> rateSpots = createRateDataPoints(measurements);

    if (offsetSpots.length < 2) {
      // Not enough data to create a meaningful chart
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Insufficient data for charting.\nPlease add more measurements.",
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      );
    }

    // Calculate min and max values for x and y axes
    double minY;
    double maxY;
    double minX;
    double maxX;

    minX = offsetSpots.isEmpty ? 0 : offsetSpots.map((e) => e.x).reduce(min);
    maxX = offsetSpots.isEmpty ? 0 : offsetSpots.map((e) => e.x).reduce(max);

    if (chartType == 'rate') {
      minY =
          rateSpots.isEmpty ? -1 : rateSpots.map((e) => e.y).reduce(min) - .5;
      maxY =
          rateSpots.isEmpty ? 1 : rateSpots.map((e) => e.y).reduce(max) + .5;
    } else {
      minY = offsetSpots.isEmpty
          ? -1
          : offsetSpots.map((e) => e.y).reduce(min) - .5;
      maxY = offsetSpots.isEmpty
          ? 1
          : offsetSpots.map((e) => e.y).reduce(max) + .5;
    }

    // Calculate intervals based on time range
    double totalTime = maxX - minX;
    double intervalX = totalTime / 5; // aim for 5 intervals

    //   List<TaggedFlSpot> calculateRateOfChange(
    //     List<TimingMeasurement> timingMeasurements) {
    //   if (timingMeasurements.length < 2)
    //     return []; // Need at least two measurements to calculate rate of change

    final xData = offsetSpots.map((e) => e.x).toList();
    final yData = offsetSpots.map((e) => e.y).toList();

    final slope = calculateSlope(xData, yData);
    final intercept = calculateIntercept(slope, xData, yData);

    // line showing the regression line of offsets over time
    final lineSpots = [
      FlSpot(minX, yData.last),
      FlSpot(maxX, slope * maxX + intercept),
    ];

    // Horizontal line at the average rate of change per day
    List<FlSpot> rateOfChangeLineSpots = [
      FlSpot(minX, slope * 86400000),
      FlSpot(maxX, slope * 86400000),
    ];

    // Define formatter based on the total duration
    String formatTimeInterval(double time) {
      if (totalTime <= 86400000) {
        // less than or equal to 24 hours
        return "${(time / 3600000).toStringAsFixed(1)}h"; // hours
      } else {
        return "${(time / 86400000).toStringAsFixed(1)}d"; // days
      }
    }

    double rangeY = maxY - minY;
    double intervalY = (rangeY / 5).ceil().toDouble();
    if (intervalY < 1) intervalY = 1;

    List<TaggedFlSpot> plotSpots =
        chartType == 'rate' ? rateSpots : offsetSpots;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.7),
              tooltipRoundedRadius: 4.0,
              tooltipPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              showOnTopOfTheChartBoxArea: true,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  // Only show tooltips for the main data line (index 0)
                  if (touchedSpot.barIndex != 0) return null;
                  
                  final tag = plotSpots[touchedSpot.spotIndex].tag;
                  if (tag == null) return null;

                  return LineTooltipItem(
                    tag,
                    TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  );
                }).toList();
              },
            ),
            getTouchedSpotIndicator: (LineChartBarData barData, List<int> indicators) {
              return indicators.map(
                (int index) {
                  // Only show indicator if the spot has a non-'No Tag' tag
                  final tag = plotSpots[index].tag;
                  if (tag == null) return null;

                  return TouchedSpotIndicatorData(
                    FlLine(
                      color: Colors.grey,
                      strokeWidth: .5,
                      dashArray: [2, 4],
                    ),
                    FlDotData(show: true),
                  );
                },
              ).toList();
            },
            getTouchLineEnd: (_, __) => double.infinity,
          ),
          lineBarsData: [
            LineChartBarData(
              spots: plotSpots,
              isCurved: false,
              color: Theme.of(context).colorScheme.tertiary,
              barWidth: 2,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 3.5,
                  color: Theme.of(context).colorScheme.tertiary,
                  strokeWidth: 1,
                  strokeColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.tertiary.withOpacity(0.15),
                    Theme.of(context).colorScheme.tertiary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
            if (this.chartType == 'offset')
              LineChartBarData(
                spots: lineSpots,
                isCurved: false,
                color: Theme.of(context).colorScheme.tertiary,
                barWidth: 2,
                dotData: FlDotData(show: false),
                isStrokeCapRound: true,
                dashArray: [5, 5],
                showingIndicators: [],
              ),
            if (this.chartType == 'rate')
              LineChartBarData(
                spots: rateOfChangeLineSpots,
                isCurved: false,
                color: Theme.of(context).colorScheme.tertiary,
                barWidth: 2,
                dotData: FlDotData(show: false), isStrokeCapRound: true,
                dashArray: [5, 5], // Optional: Makes this line dashed
              ),
          ],
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: intervalY,
            verticalInterval: intervalX,
            getDrawingVerticalLine: (value) => FlLine(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.05),
              strokeWidth: 0.5,
            ),
            getDrawingHorizontalLine: (value) => FlLine(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.05),
              strokeWidth: 0.5,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(
              axisNameWidget: Text(
                chartType == 'rate' ? 'Rate (s/day)' : 'Offset (s)',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == minY || value == maxY) return const SizedBox.shrink();
                  return SizedBox(
                    width: 35,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text(
                        '${value.toStringAsFixed(1)}s',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                        ),
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  );
                },
                interval: intervalY,
              ),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: Text(
                'Time',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              sideTitles: SideTitles(
                reservedSize: 22,
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value == minX || value == maxX) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      formatTimeInterval(value - minX),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                  );
                },
                interval: intervalX,
              ),
            ),
            topTitles: AxisTitles(
              axisNameSize: 25,
              axisNameWidget: titleText != null
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        titleText!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    )
                  : Container(),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false)
            ),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

List<TaggedFlSpot> createDataPoints(List<TimingMeasurement> measurements) {
  return measurements.map((measurement) {
    final systemTime =
        measurement.system_time.millisecondsSinceEpoch.toDouble();
    final offset = measurement.difference_ms!.toDouble() / 1000;
    final tag = measurement.tag ?? null;

    return TaggedFlSpot(systemTime, offset, tag);
  }).toList();
}
