import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void ShowReviewDialog(BuildContext context) {
  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  print(isDarkMode);

  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text('Enjoying This App?'),
      content: Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text(
            'Enjoying this app? Please leave a review on the app store!'),
      ),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text('Not Really',
              style:
                  TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
          onPressed: () {
            Posthog().capture(
              eventName: 'review_no',
              properties: {},
            );
            Navigator.of(context).pop();
            ShowFeedbackDialog(context);
          },
        ),
        CupertinoDialogAction(
          child: Text('Rate App',
              style:
                  TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
          onPressed: () async {
            Posthog().capture(
              eventName: 'review_yes',
              properties: {},
            );
            Navigator.of(context).pop();
            const url = 'https://apps.apple.com/us/app/apple-store/6452083510';
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              print('Could not launch $url');
            }
          },
          // onPressed: () {
          //   Navigator.of(context).pop();
          //   ShowRateDialog(context);
          // },
        ),
      ],
    ),
  );
}

// void ShowRateDialog(BuildContext context) {
//   bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
//   showCupertinoDialog(
//     context: context,
//     builder: (BuildContext context) => CupertinoAlertDialog(
//       title: Text('Rate on App Store'),
//       content: Padding(
//         padding: EdgeInsets.only(top: 8.0),
//         child: Text('Would you like to rate us on the App Store?'),
//       ),
//       actions: <Widget>[
//         CupertinoDialogAction(
//           child: Text('No Thanks',
//               style:
//                   TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         CupertinoDialogAction(
//           child: Text('Sure!',
//               style:
//                   TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
//           onPressed: () async {
//             Navigator.of(context).pop();
//             const url = 'https://apps.apple.com/us/app/apple-store/6452083510';
//             if (await canLaunch(url)) {
//               await launch(url);
//             } else {
//               print('Could not launch $url');
//             }
//           },
//         ),
//       ],
//     ),
//   );
// }

void ShowFeedbackDialog(BuildContext context) {
  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text('We Value Your Feedback'),
      content: Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text(
            'Please let us know what we can improve. You can leave feedback in the Info page.'),
      ),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text('OK',
              style:
                  TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
          onPressed: () {
            Navigator.of(context).pop();
            // Implement navigation to the Info page or feedback form
          },
        ),
      ],
    ),
  );
}
