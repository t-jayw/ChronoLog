import 'package:flutter/material.dart';

import '../screens/add_watch_screen.dart';


class EmptyList extends StatelessWidget {
  const EmptyList({Key? key}) : super(key: key);
  void _navigateToAddWatchScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddWatchScreen()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Center(
          child: InkWell(
onTap: () {
                _navigateToAddWatchScreen(context);
              },
            child: Card(
              
              color:Theme.of(context).colorScheme.tertiary,
              child:  Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Add a watch to get started',
                  style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
