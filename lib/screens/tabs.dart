import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronolog/screens/info_page_screen.dart';
import 'package:chronolog/screens/watchbox_screen.dart';
import '../screens/add_watch_screen.dart';

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  int _selectedPageIndex = 1;
  final List<Widget> _pages = [
    InfoPage(),
    WatchboxScreen(),
  ];
  final List<String> _pageTitles = ["Info", "ChronoLog"];

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
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (_) => InfoPage()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _pageTitles[_selectedPageIndex],
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: <Widget>[
          if (_selectedPageIndex == 1) 
          IconButton(
            icon: const Icon(Icons.add), // Plus sign icon
            onPressed: () {
              _navigateToAddWatchScreen(context);
              // showModalBottomSheet(
              //   context: context,
              //   builder: (context) {
              //     return AddWatchScreen();
              //   },
              //   isScrollControlled: true,
              //   useSafeArea: true,
              // );
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
            icon: Icon(Icons.info_outline),
            label: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.watch_outlined),
            label: 'ChronoLog',
          ),
        ],
      ),
    );
  }
}
