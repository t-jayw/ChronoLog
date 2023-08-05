import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void ShowReviewDialog(BuildContext context) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text('Enjoying this app?'),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text('No', style: TextStyle(color: Colors.red, fontSize: 20)),
          onPressed: () {
            Navigator.of(context).pop();
            ShowFeedbackDialog(context);
          },
        ),
        CupertinoDialogAction(
          child: Text('Yes', style: TextStyle(color: Colors.blue, fontSize: 20)),
          onPressed: () {
            Navigator.of(context).pop();
            ShowRateDialog(context);
          },
        ),
      ],
    ),
  );
}


void ShowRateDialog(BuildContext context) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text('Please leave us a review'),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text('No thanks', style: TextStyle(color: Colors.red, fontSize: 20)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        CupertinoDialogAction(
          child: Text('Ok', style: TextStyle(color: Colors.blue, fontSize: 20)),
          onPressed: () async {
            Navigator.of(context).pop();
            const url = 'https://apps.apple.com/us/app/apple-store/6452083510';
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
          },
        ),
      ],
    ),
  );
}


void ShowFeedbackDialog(BuildContext context) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text('Please send me feedback from the Info page!'),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text('Ok', style: TextStyle(color: Colors.blue, fontSize: 20)),
          onPressed: () {
            Navigator.of(context).pop();
            // Open the feedback form or email
          },
        ),
      ],
    ),
  );
}
