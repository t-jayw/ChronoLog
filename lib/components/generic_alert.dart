import 'package:chronolog/components/primary_button.dart';
import 'package:flutter/material.dart';

Future<void> showGenericAlert({
  required BuildContext context,
  required String title,
  required List<String> contentLines,
  String cancelButtonText = 'Okay',
  String? primaryActionText,
  VoidCallback? onPrimaryActionPressed,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // user must tap button to close
    builder: (BuildContext context) {
      return AlertDialog(
        titlePadding: EdgeInsets.all(16),
        title: Center(
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...contentLines.map((line) => Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(line, textAlign: TextAlign.center),
              )).toList(),
              SizedBox(height: 12),
              Divider(),
              if (primaryActionText != null && onPrimaryActionPressed != null) ...[
                SecondaryButton(
                  text: primaryActionText,
                  onPressed: onPrimaryActionPressed,
                ),
                Divider(),
              ],
              PrimaryButton(
                child: Text(
                  cancelButtonText,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}