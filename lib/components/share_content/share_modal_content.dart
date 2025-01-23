import 'package:chronolog/components/share_content/share_content_stats.dart';
import 'package:flutter/material.dart';
import 'package:chronolog/models/timepiece.dart';
import 'package:chronolog/components/timing_run_component.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronolog/providers/timing_run_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ShareModalContent extends ConsumerWidget {
  final Timepiece timepiece;
  final GlobalKey repaintBoundaryKey;

  const ShareModalContent({
    Key? key, 
    required this.timepiece, 
    required this.repaintBoundaryKey
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timingRuns = ref.watch(timingRunProvider(timepiece.id));
    final mostRecentRun = timingRuns.isNotEmpty ? timingRuns.first : null;

    return RepaintBoundary(
      key: repaintBoundaryKey,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: timepiece.image != null
                          ? Image.memory(timepiece.image!, fit: BoxFit.cover)
                          : SvgPicture.asset(
                              'assets/images/watch_placeholder.svg',
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Theme.of(context).colorScheme.onSurface,
                                BlendMode.srcIn,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Text(
                                timepiece.model,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onBackground,
                                ),
                              ),
                            ),
                            Text(
                              timepiece.brand,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.tertiary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (mostRecentRun != null) 
              TimingRunComponent(
                timingRun: mostRecentRun,
                timepiece: timepiece,
                navigation: false,
              )
            else
              Center(
                child: Text(
                  'No timing runs available',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ),
            Expanded(child: ShareModalStats(timepiece: timepiece)),
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/wathclogo-40@2x.png', height: 20),
                  SizedBox(width: 8),
                  Text(
                    "ChronoLog",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  Text(
                    " - Watch Accuracy",
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
