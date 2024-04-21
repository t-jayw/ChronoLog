import 'package:chronolog/components/graphs/rate_custom_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Column(
      children: [
        //SizedBox(height: 4),
        Container(
          height: 250,
          child: Card(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 4.0, 18.0, 4.0),
                child: Flex(direction: Axis.horizontal, children: [
                  RateCustomLineChart(
                    runId: runId,
                  )
                ])),
          ),
        ),
      ],
    );
  }
}
