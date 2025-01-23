import 'package:chronolog/components/premium/premium_needed_dialog.dart';
import 'package:chronolog/screens/tabs.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
        'Add measurements to Timing Runs',
        "Timing Runs are a series of measurements that ChronoLog uses to calculate statistics.",
        context
      ), 
      _createPage(
        Icons.auto_graph_sharp,
        'See trends over time',
        "Measurements should have at least 6 hours between them for best results.",
        context
      ),
      _createPremiumPage(context),
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
          if (!isLastPage) 
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1), // Low opacity background color
                  border: Border.all(color: Theme.of(context).colorScheme.tertiary), // Outline color
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const TabsScreen()),
                    );
                  },
                  child: Text('Skip', style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.tertiary)),
                ),
              ),
            ),
          if (isLastPage) 
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1), // Low opacity background color
                  border: Border.all(color: Theme.of(context).colorScheme.tertiary), // Outline color
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const TabsScreen()),
                    );
                  },
                  child: Text('Continue', style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.tertiary)),
                ),
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

  Widget _createPremiumPage(BuildContext context) {
    return const PremiumNeededDialog(
      primaryText: "Unlock all features with ChronoLog Premium!",
      reason: "welcome_screen_paywall",
    );
  }
}
