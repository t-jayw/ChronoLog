import 'dart:async';

import 'package:chronolog/database_helpers.dart';
import 'package:chronolog/models/timepiece.dart';
import 'package:chronolog/models/timing_measurement.dart';
import 'package:chronolog/models/timing_run.dart';
import 'package:chronolog/providers/theme_provider.dart';
import 'package:chronolog/providers/time_mode_provider.dart';

import 'package:chronolog/screens/welcome_screen.dart';
import 'package:chronolog/supabase_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronolog/screens/tabs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ulid/ulid.dart';

import 'components/show_review_dialog.dart';


final theme = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: Color.fromRGBO(250, 247, 240, 1),
    secondary: Color.fromRGBO(145, 120, 65, 1),
    tertiary: Color.fromRGBO(47, 75, 60, 1),
    error: Color.fromARGB(255, 171, 0, 0),
    background: Color.fromRGBO(250, 247, 240, 1),
    surface: Color.fromRGBO(242, 237, 227, 1),
  ),
  splashColor: Colors.transparent,
  fontFamily: 'SFProText',
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color.fromRGBO(10, 10, 10, 1)),
    bodyMedium: TextStyle(color: Color.fromRGBO(10, 10, 10, 1)),
    displayLarge: TextStyle(color: Color.fromRGBO(10, 10, 10, 1)),
    // You can also set other text styles if needed
  ),
  appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(
        color: Colors.black, // change this to preferred icon color
      ),
      titleTextStyle:
          TextStyle(fontFamily: 'NewYork', fontSize: 20, color: Colors.black)),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return Color.fromARGB(255, 56, 124, 68);
          }
          return Color.fromRGBO(45, 95, 60, 1);
        },
      ),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
    ),
  ),
  cardTheme: CardTheme(
    color: Color.fromRGBO(250, 247, 240, 1),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    // clipBehavior: Clip.antiAlias, // Uncomment this if you want to clip the content of the card with the shape's border.
  ),
  // the rest of your theme data...
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Color.fromRGBO(35, 80, 52, 1),
  ),
  scaffoldBackgroundColor: Color.fromRGBO(242, 237, 227, 1),
  dialogBackgroundColor: Color.fromRGBO(242, 237, 227, 1),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Color.fromRGBO(28, 28, 32, 1),
  dialogBackgroundColor: Color.fromRGBO(38, 38, 42, 1),
  colorScheme: ColorScheme.dark(
    primary: Color.fromRGBO(28, 32, 30, 1),
    secondary: Color.fromRGBO(200, 175, 120, 1),
    tertiary: Color.fromRGBO(180, 200, 190, 1),
    error: Color.fromRGBO(171, 0, 0, 1),
  ),
  splashColor: Colors.transparent,
  appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      titleTextStyle: TextStyle(fontFamily: 'NewYork', fontSize: 20)),
  fontFamily: 'SFProText',
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return Color.fromARGB(255, 45, 85, 45);
          }
          return Color.fromARGB(255, 65, 135, 85);
        },
      ),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
    ),
  ),
  cardTheme: CardTheme(
    color: Color.fromARGB(255, 45, 44, 44),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Color.fromARGB(255, 143, 240, 188),
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize RevenueCat before any other purchases code
  await Purchases.setDebugLogsEnabled(true);
  await Purchases.configure(
    PurchasesConfiguration("appl_tfJxfTZTRJfDQzENfwSdrpoTEpZ")
    // Add other configuration options as needed
  );

  final prefs = await SharedPreferences.getInstance();
  int openCount = prefs.getInt('openCount') ?? 0;
  openCount++;
  await prefs.setInt('openCount', openCount);

  clearDeprecatedSharedPreferencesKeys();

  // Attempt to fetch a stored unique identifier for the user, or generate a new one.
  String userId = prefs.getString('userId') ?? Ulid().toString();
  await prefs.setString(
      'userId', userId); // Save it back in case it was generated new
  // Identify the user in PostHog
  Posthog().identify(userId: userId);

  // Load user preferences
  final themeModeIndex = prefs.getInt('themeModeOption') ?? 0;
  final timeModeIndex = prefs.getInt('timeModeOption') ?? 0;

  await dotenv.load();

  // Backfill timepieces to Posthog
  await backfillTimepiecesToSupabase();

  runApp(
    ProviderScope(
      overrides: [
        // Initialize providers with stored preferences
        themeModeProvider
            .overrideWith((ref) => ThemeModeOption.values[themeModeIndex]),
        timeModeProvider
            .overrideWith((ref) => TimeModeOption.values[timeModeIndex]),
      ],
      child: App(
          openCount: openCount,
          themeModeOption: ThemeModeOption.values[themeModeIndex]),
    ),
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class App extends ConsumerWidget {
  final int openCount;
  bool isDialogShown = false;
  final ThemeModeOption themeModeOption;

  App({Key? key, required this.openCount, required this.themeModeOption})
      : super(key: key); // Modify this line

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use themeModeOption to determine the theme mode

    final themeModeOption = ref.watch(themeModeProvider);

    ThemeMode themeMode;
    switch (themeModeOption) {
      case ThemeModeOption.system:
        themeMode = ThemeMode.system;
        break;
      case ThemeModeOption.dark:
        themeMode = ThemeMode.dark;
        break;
      case ThemeModeOption.light:
        themeMode = ThemeMode.light;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    return MaterialApp(
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: openCount == 1
          ? WelcomeScreen()
          : openCount == 5
              ? FutureBuilder(
                  // Use a FutureBuilder to display the dialog only once after the widget is built
                  future: Future.delayed(Duration.zero),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        !isDialogShown) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Posthog().capture(
                          eventName: 'review_please',
                          properties: {},
                        );
                        ShowReviewDialog(context);
                        isDialogShown =
                            true; // set the flag to true after showing the dialog
                      });
                    }
                    return const TabsScreen();
                  },
                )
              : const TabsScreen(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
    );
  }
}

Future<void> backfillTimepiecesToSupabase() async {
  final prefs = await SharedPreferences.getInstance();
  bool backfillCompleted = prefs.getBool('v1.5.2_backfill_completed') ?? false;

  if (!backfillCompleted) {
    final List<Timepiece> timepieces = await DatabaseHelper().getTimepieces();

    // Initialize SupabaseManager and load environment variables
    final supabase = SupabaseManager();
    await supabase.init();

    for (var timepiece in timepieces) {
      print("backfilling timepiece to Supabase");
      print(timepiece.toString());

      // Instead of Posthog, insert into Supabase
      try {
        await supabase.insertEvent(timepiece, 'timepieces_events',
            customEventType: 'v1.5.2_backfill');
        print('Timepiece backfilled successfully');
      } catch (e) {
        print('Error backfilling timepiece: $e');
      }
      backfillTimingRunsToSupabase(timepiece.id);
    }
    // Mark the backfill as completed to prevent it from running again
    await prefs.setBool('v1.5.2_backfill_completed', true);
  }
}

// Backfill Timing Runs
Future<void> backfillTimingRunsToSupabase(watchId) async {
  final List<TimingRun> timingRuns =
      await DatabaseHelper().getTimingRunsByWatchId(watchId);

  final supabase = SupabaseManager();
  await supabase.init();

  for (var timingRun in timingRuns) {
    print("Backfilling timing run to Supabase: ${timingRun.id}");
    try {
      await supabase.insertEvent(timingRun, 'timing_runs_events',
          customEventType: 'v1.5.2_backfill');
      print('Timing run backfilled successfully');
    } catch (e) {
      print('Error backfilling timing run: $e');
    }

    backfillTimingMeasurementsToSupabase(timingRun.id);
  }
}

// Backfill Timing Measurements
Future<void> backfillTimingMeasurementsToSupabase(runId) async {
  final List<TimingMeasurement> timingMeasurements =
      await DatabaseHelper().getTimingMeasurementsByRunId(runId);

  final supabase = SupabaseManager();
  await supabase.init();

  for (var measurement in timingMeasurements) {
    print("Backfilling timing measurement to Supabase: ${measurement.id}");
    try {
      await supabase.insertEvent(measurement, 'timing_measurements_events',
          customEventType: 'v1.5.2_backfill');
      print('Timing measurement backfilled successfully');
    } catch (e) {
      print('Error backfilling timing measurement: $e');
    }
  }
}

Future<void> clearDeprecatedSharedPreferencesKeys() async {
  final prefs = await SharedPreferences.getInstance();

  // List of deprecated keys
  List<String> deprecatedKeys = [
    'timingMeasurementsBackfillCompleted',
    'v1.5.0_backfill_completed',
    'timingRunsBackfillCompleted',
    'timepieceBackfillCompleted'
  ];

  for (String key in deprecatedKeys) {
    if (prefs.containsKey(key)) {
      await prefs.remove(key);
      print('Removed deprecated key: $key');
    } else {
      print('Key does not exist: $key');
    }
  }
}
