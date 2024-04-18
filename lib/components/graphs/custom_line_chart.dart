import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class CustomLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final Color lineColor;
  final String? titleText;

  const CustomLineChart({
    Key? key,
    required this.spots,
    this.lineColor = Colors.orangeAccent,
    this.titleText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    double minY = spots.isEmpty ? -1 : spots.map((e) => e.y).reduce(min) - .5;
    double maxY = spots.isEmpty ? 1 : spots.map((e) => e.y).reduce(max) + .5;
    double minX = spots.isEmpty ? 0 : spots.map((e) => e.x).reduce(min);
    double maxX = spots.isEmpty ? 0 : spots.map((e) => e.x).reduce(max);
    DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

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

    return Expanded(
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: .15,
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
                              ], ),
              barWidth: 1.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius:
                        1, // Adjust the radius to increase or decrease the size of the dot
                    strokeWidth: 2,
                    strokeColor: Theme.of(context).colorScheme.tertiary,
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),
            // Average rate line
            LineChartBarData(
              spots: averageRateLineSpots,
              isCurved: false,
              color: Theme.of(context).colorScheme.tertiary,
              barWidth: .5,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            )
          ],
          gridData: FlGridData(
            drawVerticalLine: true,
            drawHorizontalLine: true,
            horizontalInterval:
                (maxY - minY) / 5, // The interval you're interested in
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 15,
                getTitlesWidget: (value, meta) {
                  if (value == minY || value == maxY) {
                    return Text(
                      '${value.toStringAsFixed(0)}', // Customize format as needed
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 20,
                
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value == minX || value == maxX) {
                    return Padding(
                      padding: EdgeInsets.only(
                          top: 6, right: 12), // Adjust padding as necessary
                      child: Text(
                        dateFormatter.format(
                            DateTime.fromMillisecondsSinceEpoch(value.toInt())),
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
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
