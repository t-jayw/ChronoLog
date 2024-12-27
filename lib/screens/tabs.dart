import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronolog/screens/info_page_screen.dart';
import 'package:chronolog/screens/watchbox_screen.dart';
import '../providers/timepiece_list_provider.dart';
import '../screens/add_watch_screen.dart';

class TabsScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const TabsScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  ConsumerState<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  late int _selectedPageIndex;
  final List<Widget> _pages = [
    WatchboxScreen(),
    InfoPage(),
  ];

  final List<String> _pageTitles = [
    "ChronoLog",
    "ChronoLog",
  ];

  @override
  void initState() {
    super.initState();
    _selectedPageIndex = widget.initialIndex;
  }

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
