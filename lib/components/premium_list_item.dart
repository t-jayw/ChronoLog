import 'package:flutter/material.dart';

class PremiumButton extends StatelessWidget {
  final Future<bool> Function() isPremiumActivated;
  final VoidCallback onTapPremium;

  PremiumButton({required this.isPremiumActivated, required this.onTapPremium});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isPremiumActivated(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the Future is complete and no errors occurred
          if (snapshot.hasData) {
            return ElevatedButton(
              //onPressed: !snapshot.data! ? onTapPremium : null,
              onPressed: onTapPremium ,
              child:
                  Text(snapshot.data! ? 'Premium Enabled!' : 'Enable Premium'),
            );
          } else if (snapshot.hasError) {
            // If we run into an error, display it to the user
            return Text('Error: ${snapshot.error}');
          }
        }
        // While the Future is not complete, display a loading indicator
        return CircularProgressIndicator();
      },
    );
  }
}
