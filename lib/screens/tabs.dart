import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronolog/screens/info_page_screen.dart';
import 'package:chronolog/screens/watchbox_screen.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/premium/premium_needed_dialog.dart';
import '../providers/timepiece_list_provider.dart';
import '../screens/add_watch_screen.dart';

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  int _selectedPageIndex = 0;
  final List<Widget> _pages = [
    WatchboxScreen(),
    InfoPage(),
  ];

  final List<String> _pageTitles = [
    "ChronoLog",
    "Info",
  ];

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _navigateToAddWatchScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddWatchScreen()),
    );
  }

  void _navigateToInfoPageScreen(BuildContext context) {
    _selectPage(2);
  }

  void _navigateToPurchasePageScreen(BuildContext context) {
    _selectPage(3);
  }

  void _showPremiumNeededDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PremiumNeededDialog(primaryText: "Free version limited to 1 timepiece",);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final timepieces = ref.watch(timepieceListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _pageTitles[_selectedPageIndex],
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: <Widget>[
          if (_selectedPageIndex == 0)
            IconButton(
              icon: const Icon(Icons.add), // Plus sign icon
              onPressed: () async {
                _navigateToAddWatchScreen(context);

                // Make it async
                
                // Turning off paywall
                // SharedPreferences prefs = await SharedPreferences.getInstance();
                // bool? isPremiumActivated = prefs.getBool('isPremiumActive');
                // int numWatches = timepieces.length;

                // if (isPremiumActivated != true && numWatches >= 1) {
                //   Posthog().capture(
                //     eventName: 'paywall',
                //     properties: {
                //       'reason': 'num_watches_paywall',
                //     },
                //   );
                //   _showPremiumNeededDialog(context);
                // } else {
                //   _navigateToAddWatchScreen(context);
                // }
              },
            ),
        ],
      ),
      body: _pages[_selectedPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        selectedItemColor: Theme.of(context).colorScheme.tertiary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.watch_outlined),
            label: 'ChronoLog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Info',
          ),
        ],
      ),
    );
  }
}
