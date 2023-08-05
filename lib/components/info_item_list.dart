
import 'package:flutter/material.dart';


class InfoItemList extends StatelessWidget {
  final List<InfoItem> items;

  InfoItemList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => Divider(color: Colors.white),
      itemBuilder: (context, index) => items[index],
    );
  }
}

class InfoItem extends StatelessWidget {
  final String title;
  final String content;
  final Icon icon;
  final List<Color> colors;

  InfoItem({
    required this.title,
    required this.content,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.primary,
      ),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          IconTheme(
            data: IconThemeData(
              color: Theme.of(context).colorScheme.tertiary,
            ),
            child: icon,
          ),
          SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 18,
                  ),
                ),
                Text(
                  content,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}