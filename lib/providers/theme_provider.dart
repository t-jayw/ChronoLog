import 'package:flutter_riverpod/flutter_riverpod.dart';


enum ThemeModeOption { system, dark, light }

final themeModeProvider = StateProvider<ThemeModeOption>((ref) => ThemeModeOption.system);

