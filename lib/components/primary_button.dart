import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;

  PrimaryButton({required this.child, required this.onPressed, });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //height: 40.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Theme.of(context).colorScheme.tertiary, // Use the primary color from your theme
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  SecondaryButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //height: 40.0,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Theme.of(context).cardColor, // Use the primary color from your theme
        ),
        onPressed: onPressed,
        child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      ),
    );
  }
}
