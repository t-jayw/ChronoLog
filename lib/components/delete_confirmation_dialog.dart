import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text("Confirm Deletion", style: TextStyle(fontWeight: FontWeight.w600, )),
      content: Text("Are you sure you wish to delete this item?", ),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text("Cancel", style: TextStyle(color: Colors.blue)),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        CupertinoDialogAction(
          child: Text("Delete", style: TextStyle(color: Colors.red)),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}
