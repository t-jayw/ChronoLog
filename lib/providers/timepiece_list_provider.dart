import 'package:chronolog/providers/posthog_manager_provider.dart';
import 'package:chronolog/providers/supabase_manager_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronolog/models/timepiece.dart';
import '../database_helpers.dart';
import 'dbHelperProvider.dart';

class TimepieceListProvider extends StateNotifier<List<Timepiece>> {
  TimepieceListProvider(this._db, this.ref) : super([]) {
    initTimepieces();
  }

  final DatabaseHelper _db;
  final ProviderContainer ref; // This will provide access to SupabaseManager

  Future<void> initTimepieces() async {
    state = await _db.getTimepieces();
  }

  void reorderTimepieces(int oldIndex, int newIndex) {
    final Timepiece timepiece = state[oldIndex];
    state = List<Timepiece>.from(state)
      ..remove(timepiece)
      ..insert(newIndex, timepiece);
  }

  Future<void> addTimepiece(Timepiece timepiece) async {
    final existingTimepiece =
        state.firstWhereOrNull((tp) => tp.id == timepiece.id);
    if (existingTimepiece == null) {
      await _db.insertTimepiece(timepiece);
      state = [...state, timepiece];

      final supabase = ref.read(supabaseManagerProvider);
      await supabase.insertEvent(timepiece, 'timepieces_events',
          customEventType: 'add_timepiece');

      // Assuming that you might want to log this addition in PostHog as well

      final posthog = ref.read(posthogManagerProvider);
      posthog.sendEvent(timepiece, customEventType: 'timepiece_added');
    }
  }

  Future<void> removeTimepiece(Timepiece timepieceToRemove) async {

    final supabase = ref.read(supabaseManagerProvider);
    await supabase.insertEvent(timepieceToRemove, 'timepieces_events',
        customEventType: 'delete_timepiece');
        
    await _db.removeTimepiece(timepieceToRemove.id);

    state = state.where((item) => item.id != timepieceToRemove.id).toList();

  }

  Future<void> updateTimepiece(Timepiece updatedTimepiece) async {
    final existingIndex =
        state.indexWhere((tp) => tp.id == updatedTimepiece.id);
    if (existingIndex != -1) {
      await _db.updateTimepiece(updatedTimepiece);
      state[existingIndex] = updatedTimepiece;
      state = List.from(state); // Notify listeners of the state change

      final supabase = ref.read(supabaseManagerProvider);
      await supabase.insertEvent(updatedTimepiece, 'timepieces_events',
          customEventType: 'update_timepiece');
    } else {
      print('Timepiece does not exist.');
    }
  }
}

final timepieceListProvider =
    StateNotifierProvider<TimepieceListProvider, List<Timepiece>>((ref) {
  final dbHelper = ref.watch(dbHelperProvider);
  return TimepieceListProvider(
      dbHelper, ref.container); // Pass ref.container to TimepieceListProvider
});

final orderedTimepiecesProvider = StateProvider<List<Timepiece>>((ref) {
  return []; // Initially empty, will be updated later
});


// SupabaseManager provider if needed




// class TimepieceList extends StateNotifier<List<Timepiece>> {
//   TimepieceList() : super([]) {
//     state = [
//       // Initialize your timepieces here
//       Timepiece(
//         id: '1',
//         name: 'Submariner',
//         brand: 'Rolex',
//         model: '114060',
//         serial: 'XYZ1234',
//         movementType: MovementType.auto,
//         purchaseDate: DateTime(2020, 11, 26),
//         notes: 'Purchased for 30th birthday.',
//         imageUrl: 'https://cdn2.jomashop.com/media/catalog/product/cache/fde19e4197824625333be074956e7640/r/o/rolex-submariner-automatic-chronometer-black-dial-mens-watch-126610lnbkso.jpg?width=546&height=546',
//       ),
//       Timepiece(
//         id: '2',
//         name: 'Speedmaster',
//         brand: 'Omega',
//         model: '311.30.42.30.01.005',
//         serial: 'ABC5678',
//         movementType: MovementType.manual,
//         purchaseDate: DateTime(2021, 6, 15),
//         imageUrl: 'https://i.redd.it/uc05o9f07gb61.jpg',
//       ),
//       Timepiece(
//         id: '3',
//         name: 'Carrera',
//         brand: 'TAG Heuer',
//         model: 'CBG2A1Z.FT6157',
//         serial: 'DEF9101',
//         movementType: MovementType.auto,
//         purchaseDate: DateTime(2022, 1, 10),
//         notes: 'Gift from wife.',
//         imageUrl: 'https://preview.redd.it/9d10cwv4bwj21.png?width=536&format=png&auto=webp&v=enabled&s=6b002e35d68f0bc8ed9773e688ab92f841e6600b',
//       ),
//     ];
//   }

//   void addTimepiece(Timepiece timepiece) {
//     state = [...state, timepiece];
//   }

//   void removeTimepiece(String id) {
//     state = state.where((timepiece) => timepiece.id != id).toList();
//   }
// }

// final timepieceListProvider = StateNotifierProvider<TimepieceList, List<Timepiece>>((ref) => TimepieceList());
