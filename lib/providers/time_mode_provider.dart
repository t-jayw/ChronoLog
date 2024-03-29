import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TimeModeOption { twelve, military }
final timeModeProvider = StateProvider<TimeModeOption>((ref) => TimeModeOption.twelve);

