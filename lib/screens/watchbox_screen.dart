import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/timepiece.dart';
import '../providers/timepiece_list_provider.dart';
import '../components/delete_confirmation_dialog.dart';
import '../components/empty_list.dart';
import '../components/new_timepiece_display.dart';

final orderedTimepiecesProvider = StateProvider<List<Timepiece>>((ref) {
  return [];
});

Future<void> saveOrder(List<String> orderedIds) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('timepieceOrder', orderedIds);
}

Future<List<String>> loadOrder() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('timepieceOrder') ?? [];
}

class WatchboxScreen extends ConsumerWidget {
  const WatchboxScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: FutureBuilder<List<String>>(
        future: loadOrder(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          }

          final orderedIds = snapshot.data!;
          final timepiecesState = ref.watch(timepieceListProvider);

          List<Timepiece> orderedTimepieces = [...timepiecesState];
          orderedTimepieces.sort((a, b) {
            int indexA = orderedIds.indexOf(a.id);
            int indexB = orderedIds.indexOf(b.id);
            if (indexA == -1) indexA = orderedTimepieces.length;
            if (indexB == -1) indexB = orderedTimepieces.length;
            return indexA.compareTo(indexB);
          });

          if (orderedTimepieces.isEmpty) {
            return const EmptyList();
          }

          return Column(
            children: [
              Expanded(
                child: ReorderableListView.builder(
                  itemCount: orderedTimepieces.length,
                  itemBuilder: (context, index) {
                    final timepiece = orderedTimepieces[index];
                    return Dismissible(
                      key: Key(timepiece.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (DismissDirection direction) async {
                        return await showCupertinoDialog<bool>(
                          context: context,
                          builder: (BuildContext context) =>
                              DeleteConfirmationDialog(),
                        );
                      },
                      onDismissed: (_) {
                        ref
                            .read(timepieceListProvider.notifier)
                            .removeTimepiece(timepiece.id);
                        orderedTimepieces.removeAt(index);
                        saveOrder(orderedTimepieces.map((e) => e.id).toList());
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        color: Theme.of(context).colorScheme.error,
                        child: const Icon(Icons.delete, size: 40),
                      ),
                      child: NewTimepieceDisplay(timepiece: timepiece),
                    );
                  },
                  onReorder: (oldIndex, newIndex) {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = orderedTimepieces.removeAt(oldIndex);
                    orderedTimepieces.insert(newIndex, item);
                    saveOrder(orderedTimepieces.map((e) => e.id).toList());
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
