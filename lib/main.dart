import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:s_player/features/state_management/audio_player_provider.dart';
import 'package:s_player/features/state_management/media_scranner_provider.dart';
import 'package:s_player/features/video/screens/play_video_screen.dart';
import 'package:s_player/features/welcome/splash_screen.dart';
import 'package:s_player/utilities/bottom_navigation/main_panel.dart';
import 'package:s_player/utilities/themes/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/audio/screens/audio_player_screen.dart';
import 'features/state_management/media_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MediaProvider(prefs)),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),

        ChangeNotifierProvider(
          create: (context) => AudioPlayerProvider(),
        ),

        ChangeNotifierProvider(
          create: (context) => MediaScannerProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Media Player',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.getTheme(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      // home: MainPanel(),
      home: SplashScreen(),
    );
  }
}