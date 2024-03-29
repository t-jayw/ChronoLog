import 'package:chronolog/providers/theme_provider.dart';
import 'package:chronolog/screens/info_page_screen.dart';
import 'package:chronolog/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronolog/screens/tabs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/show_review_dialog.dart';

Future<void> initPlatformState() async {
  await Purchases.setLogLevel(LogLevel.error);
  String testUserId = "testUser_${DateTime.now().millisecondsSinceEpoch}";

  // PurchasesConfiguration configuration = PurchasesConfiguration(
  //   "appl_tfJxfTZTRJfDQzENfwSdrpoTEpZ",
  // )..appUserID = testUserId;

  PurchasesConfiguration configuration =
      PurchasesConfiguration("appl_tfJxfTZTRJfDQzENfwSdrpoTEpZ");

  print(configuration.toString());
  await Purchases.configure(configuration);
}

final theme = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: Color.fromARGB(255, 255, 255, 255),
    secondary: Color.fromRGBO(177, 164, 42, 1),
    tertiary: Color.fromRGBO(35, 80, 52, 1),
    error: Color.fromARGB(255, 243, 165, 163),
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
            return Color.fromARGB(
                255, 73, 124, 73); // the color when button is pressed
          }
          return Color.fromRGBO(35, 80, 52, 1); // default color
        },
      ),
      foregroundColor:
          MaterialStateProperty.all<Color>(Colors.black), // text color
    ),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    // clipBehavior: Clip.antiAlias, // Uncomment this if you want to clip the content of the card with the shape's border.
  ),
  // the rest of your theme data...
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Color.fromRGBO(35, 80, 52, 1),
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Color.fromRGBO(17, 6, 6, 1),
    secondary: Color.fromRGBO(221, 204, 51, 1),
    // tertiary: Color.fromARGB(255, 143, 240, 188),
    tertiary: Color.fromRGBO(178, 227, 232, 1),
    error: Color.fromARGB(158, 172, 17, 12),
  ),
  splashColor: Colors.transparent,
  appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(
        color: Colors.white, // change this to preferred icon color
      ),
      titleTextStyle: TextStyle(fontFamily: 'NewYork', fontSize: 20)),
  fontFamily: 'SFProText',
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return Color.fromARGB(
                255, 34, 34, 34); // the color when button is pressed
          }
          return Color.fromARGB(255, 73, 124, 73); // default color
        },
      ),
      foregroundColor:
          MaterialStateProperty.all<Color>(Colors.white), // text color
    ),
  ),
  cardTheme: CardTheme(
    color: Color.fromARGB(255, 90, 85, 85),
    elevation: 5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
  ),
  // the rest of your theme data...
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Color.fromARGB(255, 143, 240, 188),
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPlatformState();

  final prefs = await SharedPreferences.getInstance();
  int openCount = prefs.getInt('openCount') ?? 0;
  openCount++;
  await prefs.setInt('openCount', openCount);

  runApp(
    ProviderScope(
      child: App(openCount: openCount),
    ),
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class App extends ConsumerWidget {
  final int openCount;
  bool isDialogShown = false; // add this flag

  App({Key? key, required this.openCount}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
