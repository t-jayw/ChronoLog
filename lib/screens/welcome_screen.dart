import 'package:chronolog/screens/tabs.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../components/info_item_list.dart';
import '../components/primary_button.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _controller = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _createPage(
        Icons.watch,
        'Add watches to your collection',
        "Use ChronoLog to measure your watches' offset from true time.",
        context
      ), 
      _createPage(
        Icons.timer_sharp,
        'Add measurements to timing runs',
        "ChronoLog will calculate statistics to help you track your watches' performance over time.",
        context
      ), 
      _createPage(
        Icons.auto_graph_sharp,
        'See trends over time',
        "Measurements should have at least 6 hours between them for best results.",
        context
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('ChronoLog'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return pages[index];
                },
                onPageChanged: (page) {
                  setState(() {
                    isLastPage = page == pages.length - 1;
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SmoothPageIndicator(
              controller: _controller,
              count: pages.length,
              effect: JumpingDotEffect(activeDotColor: Theme.of(context).colorScheme.tertiary),

              onDotClicked: (index) {
                _controller.animateToPage(
                  index,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
              },
            ),
          ),
          if (isLastPage) 
            Padding(
              padding: const EdgeInsets.fromLTRB(18,10,18,20),
              child: Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const TabsScreen()),
                        );
                      },
                      child: Text('Continue', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    ),
                  ),

                ],
              ),
            ),
                          SizedBox(height: 50),

        ],
      ),
    );
  }

  Widget _createPage(IconData icon, String title, String content, context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontSize: 24, color: Theme.of(context).colorScheme.tertiary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
