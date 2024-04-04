import 'package:flutter/material.dart';

class CustomToolTip extends StatelessWidget {
  final Widget child;
  final MainAxisAlignment mainAxisAlignment;

  CustomToolTip({required this.child, required this.mainAxisAlignment});

  @override
  Widget build(BuildContext context) {

    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          mainAxisAlignment: mainAxisAlignment,
          children: [
            Icon(Icons.lightbulb_outline,
                size: 14.0, color: Theme.of(context).colorScheme.secondary),
            SizedBox(width: 5.0), // control space between icon and text
            child,
          ],
        ),
      
    );
  }
}
