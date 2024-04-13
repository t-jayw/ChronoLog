import 'package:chronolog/posthog_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final posthogManagerProvider = Provider<PosthogManager>((ref) {
  return PosthogManager();
});