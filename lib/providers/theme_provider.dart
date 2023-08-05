import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/info_page_screen.dart';

final themeModeProvider = StateProvider<ThemeModeOption>((ref) => ThemeModeOption.system);

final firstTimeProvider = StateProvider<bool>((ref) => false);
