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

    return Expanded(
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          lineTouchData: LineTouchData(
              enabled: true,
              touchCallback:
                  (FlTouchEvent event, LineTouchResponse? touchResponse) {
                // TODO : Utilize touch event here to perform any operation
              },
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.9),
                tooltipRoundedRadius: 8.0,
                showOnTopOfTheChartBoxArea: true,
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                tooltipMargin: 8,
                tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                tooltipBorder: BorderSide.none,
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((LineBarSpot touchedSpot) {
                    final TextStyle textStyle = TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    );

                    if (touchedSpot.barIndex == 0) {
                      return LineTooltipItem(
                        '${plotSpots[touchedSpot.spotIndex].tag}',
                        textStyle,
                      );
                    }
                    return null;
                  }).toList();
                },
              ),
              getTouchedSpotIndicator: (LineChartBarData barData, List<int> indicators) {
                return indicators.map((int index) {
                  return TouchedSpotIndicatorData(
                    FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 0.5),
                    FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 3,
                        color: Colors.orangeAccent,
                        strokeWidth: 2,
                        strokeColor: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  );
                }).toList();
              }),
          lineBarsData: [
            LineChartBarData(
              spots: plotSpots,
              isCurved: false,
              color: Colors.orangeAccent,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: <Color>[
                  //Color(0xff1f005c),
                  //Color(0xff5b0060),
                  Color(0xff870160),
                  Color(0xffac255e),
                  Color(0xffca485c),
                  Color(0xffe16b5c),
                  Color(0xfff39060),
                  Color(0xffffb56b),
                ], // Gradient from https://learnui.design/tools/gradient-generator.html
                tileMode: TileMode.mirror,
              ),
              barWidth: 1.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius:
                        1, // Adjust the radius to increase or decrease the size of the dot
                    color: Colors.orangeAccent,
                    strokeWidth: 2,
                    strokeColor: Theme.of(context).colorScheme.tertiary,
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),
            if (this.chartType == 'offset')
              LineChartBarData(
                spots: lineSpots,
                isCurved: false,
                color: Theme.of(context).colorScheme.tertiary,
                barWidth: 2,
                dotData: FlDotData(show: false),
                isStrokeCapRound: true,
                dashArray: [5, 5], // Optional: Makes this line dashed
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
            drawHorizontalLine: true,
            verticalInterval: intervalX,
            horizontalInterval: intervalY,
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
                strokeWidth: 0.5,
              );
            },
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
                strokeWidth: 0.5,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value == minY || value == maxY) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '${value.toStringAsFixed(0)}s',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                },
                interval: intervalY,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 20,
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value == minX || value == maxX) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      formatTimeInterval(value - minX),
                      style: TextStyle(
                        fontSize: 10,
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
                  ? Text(titleText!, style: TextStyle(fontSize: 12))
                  : Container(),
            ),
            rightTitles: AxisTitles(),
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
    final tag = measurement.tag ?? 'No Tag';

    return TaggedFlSpot(systemTime, offset, tag);
  }).toList();
}
