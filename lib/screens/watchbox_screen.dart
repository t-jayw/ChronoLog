import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../components/delete_confirmation_dialog.dart';
import '../components/empty_list.dart';
import '../components/new_timepiece_display.dart';
import '../providers/timepiece_list_provider.dart';

class WatchboxScreen extends ConsumerWidget {
  const WatchboxScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timepiecesState = ref.watch(timepieceListProvider);

    if (timepiecesState.isEmpty) {
      return const EmptyList();
    }

    return Scaffold(
      body: 
      
      Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              itemCount: timepiecesState.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  // Key must be unique for all children.
                  key: Key(timepiecesState[index].id.toString()),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (DismissDirection direction) async {
                    final bool? confirmDeletion = await showCupertinoDialog<bool>(
                      context: context,
                      builder: (BuildContext context) => DeleteConfirmationDialog(),
                    );
          
                    // If the dialog is dismissed, it will return null
                    if (confirmDeletion == true) {
                      // Perform the deletion operation in a separate microtask to allow the UI to update first
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref
                            .read(timepieceListProvider.notifier)
                            .removeTimepiece(timepiecesState[index].id);
                      });
                    }
          
                    return confirmDeletion == true;
                  },
          
                  background: Container(
                    //color: Theme.of(context).colorScheme.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                      size: 40
                    ),
                  ),
                  child: NewTimepieceDisplay(timepiece: timepiecesState[index]),
                );
              },
              onReorder: (oldIndex, newIndex) {
                // This line is important if you are removing items from the list
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
          
                // Call the reorder function in the state
                ref
                    .read(timepieceListProvider.notifier)
                    .reorderTimepieces(oldIndex, newIndex);
              },
            ),
          ),
        ],
      ),
    );
  }
}
