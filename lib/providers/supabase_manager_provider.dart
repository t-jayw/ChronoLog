import 'package:chronolog/supabase_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final supabaseManagerProvider = Provider<SupabaseManager>((ref) {
  return SupabaseManager();
});