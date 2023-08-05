import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database_helpers.dart';


final dbHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});