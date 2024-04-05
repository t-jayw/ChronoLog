import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data_helpers.dart/linear_regression.dart';
import '../../providers/timing_measurements_list_provider.dart';
import '../../models/timing_measurement.dart';
import 'package:fl_chart/fl_chart.dart';

class TaggedFlSpot extends FlSpot {
  final String tag;

  TaggedFlSpot(double x, double y, this.tag) : super(x, y);
}

class TimingRunMeasurementsRateGraph extends ConsumerWidget {
  final String runId;

  const TimingRunMeasurementsRateGraph({super.key, required this.runId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timingMeasurements = ref.watch<List<TimingMeasurement>>(
      timingMeasurementsListProvider(runId),
    );

    final data = List<TaggedFlSpot>.generate(timingMeasurements.length, (i) {
      final currentSystemTime =
          timingMeasurements[i].system_time.millisecondsSinceEpoch.toDouble();

      if (i == timingMeasurements.length - 1) {
        //return FlSpot.nullSpot;
        return TaggedFlSpot(currentSystemTime, 0, '');
      }
      final currentOffset =
          timingMeasurements[i].difference_ms!.toDouble() / 1000;

      final previousSystemTime = timingMeasurements[i + 1]
          .system_time
          .millisecondsSinceEpoch
          .toDouble();
      final previousOffset =
          timingMeasurements[i + 1].difference_ms!.toDouble() / 1000;

      final timeDifference = (currentSystemTime - previousSystemTime) /
          1000 /
          60 /
          60 /
          24; // Time difference in days.
      final rateOfChange = (currentOffset - previousOffset) /
          timeDifference; // Rate of change per day.
      final tag = timingMeasurements[i].tag != null
          ? timingMeasurements[i].tag
          : 'No Tag';

      return TaggedFlSpot(currentSystemTime, rateOfChange, tag!);
    });

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
    final averageRate =
        data.map((spot) => spot.y).reduce((a, b) => a + b) / data.length;

    final lineSpots = [
      FlSpot(minX, slope * minX + intercept),
      FlSpot(maxX, slope * maxX + intercept),
    ];

    double range = maxY - minY;
    double interval = 1;

    if (range <= 10) {
      interval = 1;
    } else if (range <= 100) {
      interval = 10;
    } else if (range <= 1000) {
      interval = 100;
    } else {
      interval = 1000;
    }

    return Column(
      children: [
        //SizedBox(height: 4),
        Container(
          height: 250,
          child: Card(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 4.0, 18.0, 8.0),
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
                                if (touchedSpots.isEmpty) {
                                  return [];
                                }

                                const textStyle = TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                );

                                return touchedSpots
                                    .map((touchedSpot) => LineTooltipItem(
                                          data[touchedSpot.spotIndex].tag,
                                          textStyle,
                                        ))
                                    .toList();
                              },
                            ),
                            getTouchedSpotIndicator: (LineChartBarData barData,
                                List<int> indicators) {
                              return indicators.map(
                                (int index) {
                                  final line = FlLine(
                                      color: Colors.grey,
                                      strokeWidth: 1,
                                      dashArray: [2, 4]);
                                  return TouchedSpotIndicatorData(
                                    line,
                                    FlDotData(show: false),
                                  );
                                },
                              ).toList();
                            },
                            getTouchLineEnd: (_, __) => double.infinity),
                        lineBarsData: [
                          LineChartBarData(
                            spots: data.sublist(0, data.length - 1),
                            isCurved: true,
                            curveSmoothness: .05,
                            preventCurveOverShooting: true,
                            isStrokeCapRound: true,
                            color: Colors.orangeAccent,
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.center,
                              colors: <Color>[
                                // Color(0xff1f005c),
                                // Color(0xff5b0060),
                                Color(0xff870160),
                                Color(0xffac255e),
                                Color(0xffca485c),
                                Color(0xffe16b5c),
                                Color(0xfff39060),
                                Color(0xffffb56b),
                              ], // Gradient from https://learnui.design/tools/gradient-generator.html
                              tileMode: TileMode.mirror,
                            ),
                            barWidth: 2,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            axisNameWidget: Text(
                              'seconds per day',
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
                                interval: interval,
                                getTitlesWidget: (value, meta) {
                                  return Text(value.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ));
                                }),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            axisNameSize: 20,
                            axisNameWidget: Text(
                              'Rate',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            axisNameWidget: Text('days',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    fontSize: 10)),
                            axisNameSize: 20,
                            sideTitles: SideTitles(
                              reservedSize: 22,
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
                          horizontalInterval: interval,
                        ),
                        borderData: FlBorderData(show: true),
                        extraLinesData: ExtraLinesData(horizontalLines: [
                          HorizontalLine(
                            y: averageRate,
                            color: Theme.of(context).colorScheme.tertiary,
                            strokeWidth: 2,
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
