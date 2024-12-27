import 'package:chronolog/components/ads/footer_banner_ad.dart';
import 'package:chronolog/models/timepiece.dart';
import 'package:flutter/material.dart';
import 'package:chronolog/components/measurement/timing_measurements_container.dart';
import 'package:chronolog/components/graphs/timing_run_measurements_offset_graph.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../components/graphs/timing_run_measurements_rate_graph.dart';
import '../components/timing_run_component.dart';
import '../models/timing_run.dart';

class TimingRunDetails extends StatefulWidget {
  final TimingRun timingRun;
  final Timepiece timepiece;

  TimingRunDetails({Key? key, required this.timingRun, required this.timepiece})
      : super(key: key);

  @override
  _TimingRunDetailsState createState() => _TimingRunDetailsState();
}

class _TimingRunDetailsState extends State<TimingRunDetails> with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Posthog().screen(
      screenName: 'timing_run_details',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Timing Run Details',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      ),
      body: Column(
        children: [
          TimingRunComponent(
            timingRun: widget.timingRun,
            timepiece: widget.timepiece,
            isMostRecent: true,
            navigation: false,
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Graphs'),
              Tab(text: 'Measurements'),
            ],
            labelColor: Theme.of(context).colorScheme.onSurface,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            indicatorColor: Theme.of(context).colorScheme.secondary,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Graphs tab
                Container(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 250,
                          child: PageView(
                            controller: _pageController,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: TimingRunMeasurementsOffsetGraph(runId: widget.timingRun.id),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: TimingRunMeasurementsRateGraph(runId: widget.timingRun.id),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: 2,
                            effect: JumpingDotEffect(
                              dotHeight: 8,
                              dotWidth: 8,
                              activeDotColor: Theme.of(context).colorScheme.onSurface,
                            ),
                            onDotClicked: (index) => _pageController.animateToPage(
                              index,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.ease,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Measurements tab
                Container(
                  child: TimingMeasurementsContainer(
                    timingRunId: widget.timingRun.id,
                  ),
                ),
              ],
            ),
          ),
          FooterBannerAdWidget(),
        ],
      ),
    );
  }
}
