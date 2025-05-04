import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stuff_app/firebase_options.dart';
import 'package:stuff_app/pages/auth/route_login.dart';
import 'package:stuff_app/states/app_state.dart';
import 'package:stuff_app/states/user_state.dart';
import 'package:stuff_app/widgets/ui_color.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'main.g.dart';

@HiveType(typeId: 1)
class GeminiAPIKey {
  GeminiAPIKey({required this.apiKey});

  @HiveField(0)
  String apiKey;
}

@HiveType(typeId: 2)
class CounterData extends HiveObject {
  @HiveField(0)
  int count = 0;

  @HiveField(1)
  DateTime? lastIncrementTime;

  @HiveField(2)
  List<int> history = [];

  @HiveField(3)
  List<DateTime> historyTimestamps = [];
}

@HiveType(typeId: 3)
class TimerSession extends HiveObject {
  @HiveField(0)
  DateTime startTime = DateTime.now();

  @HiveField(1)
  DateTime? endTime;

  @HiveField(2)
  int durationInSeconds = 0;

  @HiveField(3)
  String? notes;

  @HiveField(4)
  bool completed = false;
}

@HiveType(typeId: 4)
class TimerData extends HiveObject {
  @HiveField(0)
  List<TimerSession> sessions = [];

  @HiveField(1)
  int totalTimeInSeconds = 0;

  @HiveField(2)
  TimerSession? activeSession;

  @HiveField(3)
  int accumulatedSeconds = 0;

  @HiveField(4)
  bool isRunning = false;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!kIsWeb) {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final path = appDocumentDir.path;

    await Hive.initFlutter(path);

    Hive.registerAdapter(GeminiAPIKeyAdapter());
    Hive.registerAdapter(CounterDataAdapter());
    Hive.registerAdapter(TimerSessionAdapter());
    Hive.registerAdapter(TimerDataAdapter());

    await Hive.openBox('geminiBox');
    await Hive.openBox<CounterData>('counterBox');
    await Hive.openBox<TimerData>('timerBox');
  }

  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AppState(savedThemeMode: savedThemeMode ?? AdaptiveThemeMode.dark),
        ),
        ChangeNotifierProvider(create: (context) => UserState()),
      ],
      child: AdaptiveTheme(
        light: lightTheme,
        dark: darkTheme,
        initial: savedThemeMode ?? AdaptiveThemeMode.dark,
        builder:
            (light, dark) => MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: light,
              darkTheme: dark,
              home: const RouteLoginPage(),
            ),
      ),
    );
  }
}
