import 'package:chronolog/components/graphs/offset_custom_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class CustomLineChart extends StatelessWidget {
  final List<TaggedFlSpot> spots;
  final Color lineColor;
  final String? titleText;
  final bool showSlope;
  final bool showAverageLine;

  const CustomLineChart({
    Key? key,
    required this.spots,
    this.lineColor = Colors.orangeAccent,
    this.titleText,
    this.showSlope = true,
    this.showAverageLine = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double minY = spots.isEmpty ? -1 : spots.map((e) => e.y).reduce(min) - .5;
    double maxY = spots.isEmpty ? 1 : spots.map((e) => e.y).reduce(max) + .5;
    double minX = spots.isEmpty ? 0 : spots.map((e) => e.x).reduce(min);
    double maxX = spots.isEmpty ? 0 : spots.map((e) => e.x).reduce(max);

    // Calculate the slope and y-intercept for the average rate line
    double slope = 0;
    double yIntercept = 0;
    if (spots.length > 1) {
      double firstY = spots.first.y;
      double lastY = spots.last.y;
      double firstX = spots.first.x;
      double lastX = spots.last.x;
      slope = (lastY - firstY) / (lastX - firstX);
      yIntercept = firstY - slope * firstX;
    }

    List<FlSpot> averageRateLineSpots = [
      FlSpot(minX, minX * slope + yIntercept),
      FlSpot(maxX, maxX * slope + yIntercept),
    ];

    // Calculate the average rate of change for horizontal line
    double averageRateOfChange = 0;
    if (spots.length > 2) {
      double firstY = spots[1].y;
      double lastY = spots.last.y;
      double firstX = spots[1].x;
      double lastX = spots.last.x;
      averageRateOfChange = -1 * (lastY - firstY) / (lastX - firstX);

    }
    // Horizontal line at the average rate of change per day
    List<FlSpot> rateOfChangeLineSpots = [
      FlSpot(minX, averageRateOfChange * 86400000),
      FlSpot(maxX, averageRateOfChange * 86400000),
    ];

    // Calculate intervals based on time range
    double totalTime = maxX - minX;
    double intervalX = totalTime / 5; // aim for 5 intervals

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
                tooltipBgColor: Theme.of(context).colorScheme.secondary,
                tooltipRoundedRadius: 3.0,
                showOnTopOfTheChartBoxArea: true,
                fitInsideHorizontally: true,
                tooltipMargin: 0,
                tooltipPadding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                tooltipBorder: BorderSide(color: Colors.black),
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((LineBarSpot touchedSpot) {
                    final TextStyle textStyle = const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    );

                    // Check if the current touched spot belongs to the actual data line (index 1)
                    if (touchedSpot.barIndex == 1) {
                      // Check if the current touched spot is the highest spot in the list of touched spots
                      if (touchedSpot ==
                          touchedSpots.reduce(
                              (curr, next) => curr.y > next.y ? curr : next)) {
                        return LineTooltipItem(
                          '${spots[touchedSpot.spotIndex].tag}',
                          textStyle,
                        );
                      }
                    }

                    // If the current touched spot isn't the highest or doesn't belong to actual data line, don't display any tooltip
                    return null;
                  }).toList();
                },
              ),
              getTouchedSpotIndicator:
                  (LineChartBarData barData, List<int> indicators) {
                return indicators.map(
                  (int index) {
                    final line = FlLine(
                        color: Colors.grey, strokeWidth: .5, dashArray: [2, 4]);
                    return TouchedSpotIndicatorData(
                      line,
                      FlDotData(show: true),
                    );
                  },
                ).toList();
              },
              getTouchLineEnd: (_, __) => double.infinity),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: .15,
              preventCurveOverShooting: true,
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
            if (showSlope)
              LineChartBarData(
                spots: averageRateLineSpots,
                isCurved: false,
                color: Theme.of(context).colorScheme.tertiary,
                barWidth: 2,
                dotData: FlDotData(show: false),
                isStrokeCapRound: true,
                dashArray: [5, 5], // Optional: Makes this line dashed
              ),
            if (showAverageLine)
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
            drawVerticalLine: true,
            verticalInterval: intervalX,
            drawHorizontalLine: true,
            horizontalInterval: intervalY,
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 25,
                getTitlesWidget: (value, meta) {
                  if (value == minY) return const SizedBox.shrink();
                  return Text(
                    '${value.toStringAsFixed(0)}s',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 8,
                    ),
                  );
                },
                interval: intervalY, // Match grid interval
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 20,
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value == minX) return const SizedBox.shrink();
                  return Text(
                    formatTimeInterval(value - minX),
                    style: TextStyle(
                      fontSize: 8,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  );
                },
                interval: intervalX, // Match grid interval
              ),
            ),
            topTitles: AxisTitles(
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
