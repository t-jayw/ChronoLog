import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data_helpers.dart/linear_regression.dart';
import '../../providers/timing_measurements_list_provider.dart';
import '../../models/timing_measurement.dart';
import 'package:fl_chart/fl_chart.dart';

class TaggedFlSpot extends FlSpot {
  final String tag;

  TaggedFlSpot(double x, double y, this.tag,) : super(x, y);
}

class TimingRunMeasurementsOffsetGraph extends ConsumerWidget {
  final String runId;

  const TimingRunMeasurementsOffsetGraph({super.key, required this.runId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timingMeasurements = ref.watch<List<TimingMeasurement>>(
      timingMeasurementsListProvider(runId),
    );

    List<TaggedFlSpot> createDataPoints(List<TimingMeasurement> measurements) {
    return measurements.map((measurement) {
      final systemTime = measurement.system_time.millisecondsSinceEpoch.toDouble();
      final offset = measurement.difference_ms!.toDouble() / 1000;
      final tag = measurement.tag ?? 'No Tag';
      return TaggedFlSpot(systemTime, offset, tag);
    }).toList();
  }

  List<TaggedFlSpot> data = createDataPoints(timingMeasurements);

    double minY = data.isEmpty
        ? -1
        : data.reduce((curr, next) => curr.y < next.y ? curr : next).y - 1;
    double maxY = data.isEmpty
        ? 1
        : data.reduce((curr, next) => curr.y > next.y ? curr : next).y + 1;
    double minX = data.isEmpty
        ? 0
        : data.reduce((curr, next) => curr.x < next.x ? curr : next).x;
    double maxX = data.isEmpty
        ? 0
        : data.reduce((curr, next) => curr.x > next.x ? curr : next).x;

    final xData = data.map((e) => e.x).toList();
    final yData = data.map((e) => e.y).toList();

    final slope = calculateSlope(xData, yData);
    final intercept = calculateIntercept(slope, xData, yData);

    final lineSpots = [
      FlSpot(minX, slope * minX + intercept),
      FlSpot(maxX, slope * maxX + intercept),
    ];

    return Column(
      children: [
        //SizedBox(height: 0),
        Container(
          height: 250,
          // decoration: const BoxDecoration(
          //   gradient: LinearGradient(
          //       begin: Alignment.topLeft,
          //       end: Alignment.bottomRight,
          //       colors: [
          //         Color.fromARGB(255, 1, 1, 1),
          //         Color.fromARGB(255, 219, 229, 229)
          //       ]),
          // ),
          child: Card(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 4.0, 18.0, 4.0),
                    child: LineChart(
                      LineChartData(
                        minX: minX,
                        maxX: maxX,
                        minY: minY > 0 ? -1 : minY,
                        maxY: maxY,
                        lineTouchData: LineTouchData(
                            enabled: true,
                            touchCallback: (FlTouchEvent event,
                                LineTouchResponse? touchResponse) {
                              // TODO : Utilize touch event here to perform any operation
                            },
                            touchTooltipData: LineTouchTooltipData(
                              tooltipBgColor:
                                  Theme.of(context).colorScheme.secondary,
                              tooltipRoundedRadius: 3.0,
                              showOnTopOfTheChartBoxArea: true,
                              fitInsideHorizontally: true,
                              tooltipMargin: 0,
                              tooltipPadding:
                                  const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                              tooltipBorder: BorderSide(color: Colors.black),
                              getTooltipItems:
                                  (List<LineBarSpot> touchedSpots) {
                                return touchedSpots
                                    .map((LineBarSpot touchedSpot) {
                                  final TextStyle textStyle = const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  );

                                  // Check if the current touched spot belongs to the actual data line (index 1)
                                  if (touchedSpot.barIndex == 1) {
                                    // Check if the current touched spot is the highest spot in the list of touched spots
                                    if (touchedSpot ==
                                        touchedSpots.reduce((curr, next) =>
                                            curr.y > next.y ? curr : next)) {
                                      return LineTooltipItem(
                                        '${data[touchedSpot.spotIndex].tag}',
                                        textStyle,
                                      );
                                    }
                                  }

                                  // If the current touched spot isn't the highest or doesn't belong to actual data line, don't display any tooltip
                                  return null;
                                }).toList();
                              },
                            ),
                            getTouchedSpotIndicator: (LineChartBarData barData,
                                List<int> indicators) {
                              return indicators.map(
                                (int index) {
                                  final line = FlLine(
                                      color: Colors.grey,
                                      strokeWidth: .5,
                                      dashArray: [2, 4]);
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
                            spots: lineSpots,
                            isCurved: false,
                            dotData: FlDotData(show: false),
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          LineChartBarData(
                            spots: data,
                            isCurved: true,
                            curveSmoothness: .1,
                            preventCurveOverShooting: false,
                            isStrokeCapRound: true,
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
                            barWidth: 1,
                            dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 1, // Adjust the radius to increase or decrease the size of the dot
                          color: Colors.orangeAccent,
                          strokeWidth: 2,
                          strokeColor: Theme.of(context).colorScheme.tertiary,
                        );
                      },
                    ),
                            belowBarData: BarAreaData(show: false),

                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            axisNameWidget: Text(
                              'seconds',
                              style: TextStyle(
                                fontSize: 10,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                            axisNameSize: 20,
                            sideTitles: SideTitles(
                              reservedSize: 32,
                              showTitles: true,
                              interval: (maxY - minY) /
                                  4, // The interval you're interested in
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            axisNameSize: 20,
                            axisNameWidget: Text(
                              'Offset',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            axisNameWidget: Text(
                              'days',
                              style: TextStyle(
                                fontSize: 10,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                            axisNameSize: 14,
                            sideTitles: SideTitles(
                              reservedSize: 20,
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                String textVal = "";
                                if (value == minX) {
                                  textVal = '0.0';
                                } else if (value == maxX) {
                                  double msDiff = maxX - minX;
                                  msDiff = msDiff / 1000 / 60 / 60 / 24;
                                  textVal = '${msDiff.toStringAsFixed(1)}';
                                }
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0, 4.0, 0.0, 0.0),
                                  child: Text(textVal,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                          fontSize: 10)),
                                );
                              },
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          drawVerticalLine: true,
                          drawHorizontalLine: true,
                          horizontalInterval: (maxY - minY) /
                              3, // The interval you're interested in
                        ),
                        borderData: FlBorderData(show: true),
                        extraLinesData: ExtraLinesData(horizontalLines: [
                          HorizontalLine(
                            y: 0,
                            color: Colors.black,
                            strokeWidth: .5,
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
                // if (lastSpotData != null)
                //   Padding(
                //     padding: const EdgeInsets.only(left: 8.0),
                //     child: Text(
                //       lastSpotData.y.toString(),
                //       style: TextStyle(fontSize: 20),
                //     ),
                //   ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
