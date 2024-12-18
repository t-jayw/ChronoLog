import 'package:flutter/material.dart';

class PremiumFeatures extends StatelessWidget {
  final String entitlementType;

  const PremiumFeatures({
    Key? key,
    required this.entitlementType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color tertiaryColor = Theme.of(context).colorScheme.tertiary;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Text(
              "Features",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: tertiaryColor, 
              ),
            ),
          ),
          Divider(color: Theme.of(context).colorScheme.onSurface, thickness: 2), 
          SizedBox(height: 12), 

          // Now using the PremiumFeatureItem widget
          PremiumFeatureItem(feature: "Ads Free Experience!"),
          PremiumFeatureItem(feature: "Add unlimited watches."),
          PremiumFeatureItem(feature: "Start unlimited timing runs."),
          PremiumFeatureItem(feature: "Take unlimited measurements."),
          PremiumFeatureItem(feature: "Support continued development."),
          PremiumFeatureItem(feature: "Prioritized feedback and first look at all new features."),
        ],
      ),
    );
  }
}


class PremiumFeatureItem extends StatelessWidget {
  final String feature;

  PremiumFeatureItem({required this.feature});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.inverseSurface,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded( // Wrap the inner Row with Expanded
              child: Row(
                children: [
                  Icon(Icons.star, color: Theme.of(context).colorScheme.secondary),
                  SizedBox(width: 10.0),
                  Expanded( 
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
            // Icon(Icons.navigate_next, color: Theme.of(context).colorScheme.onSurface),
          ],
        ),
      ),
    );
  }
}

