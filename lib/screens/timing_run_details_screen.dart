import 'package:chronolog/components/ads/footer_banner_ad.dart';
import 'package:chronolog/models/timepiece.dart';
import 'package:flutter/material.dart';
import 'package:chronolog/components/measurement/timing_measurements_container.dart';
import 'package:chronolog/components/graphs/timing_run_measurements_offset_graph.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../components/graphs/timing_run_measurements_rate_graph.dart';
import '../components/timing_run_details_header_stats.dart';
import '../models/timing_run.dart';

class TimingRunDetails extends StatefulWidget {
  final TimingRun timingRun;
  final Timepiece timepiece;

  TimingRunDetails({Key? key, required this.timingRun, required this.timepiece})
      : super(key: key);

  @override
  _TimingRunDetailsState createState() => _TimingRunDetailsState();
}

class _TimingRunDetailsState extends State<TimingRunDetails> {
  final _controller = PageController();
  double _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    Posthog().screen(
      screenName: 'timing_run_details',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.timepiece.brand} ${widget.timepiece.model}',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            
            TimingRunDetailHeaderStats(timingRun: widget.timingRun),

            Container(
              height: 260, // Adjust as needed
              child: PageView(
                controller: _controller,
                children: <Widget>[
                  TimingRunMeasurementsOffsetGraph(runId: widget.timingRun.id),
                  TimingRunMeasurementsRateGraph(runId: widget.timingRun.id),

                  // Add other graphs here
                ],
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page.toDouble();
                  });
                },
              ),
            ),
            SmoothPageIndicator(
                controller: _controller, // PageController
                count: 2, // Number of pages
                
                effect: JumpingDotEffect(
                    activeDotColor: Theme.of(context)
                        .colorScheme
                        .tertiary), // your preferred effect
                onDotClicked: (index) {
                  _controller.animateToPage(
                    index,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                }),

            Expanded(
              child:
                  TimingMeasurementsContainer(timingRunId: widget.timingRun.id),
            ),
                                            FooterBannerAdWidget(),

          ],
        ),
      ),
    );
  }
}
