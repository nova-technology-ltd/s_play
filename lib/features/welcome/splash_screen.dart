import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:s_player/features/state_management/audio_player_provider.dart';
import 'package:s_player/utilities/bottom_navigation/main_panel.dart';
import 'package:s_player/utilities/themes/theme_provider.dart';

import '../state_management/media_scranner_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    try {
      // Wait for media scanning to complete
      final mediaScanner = Provider.of<MediaScannerProvider>(
        context,
        listen: false,
      );
      await Future.delayed(
        const Duration(seconds: 3),
      ); // Simulate splash duration

      // Restore last played audio
      final audioPlayer = Provider.of<AudioPlayerProvider>(
        context,
        listen: false,
      );
      if (audioPlayer.currentMedia != null) {
        final audioExists = mediaScanner.audios.any(
          (audio) => audio['path'] == audioPlayer.currentMedia,
        );
        if (audioExists) {
          await audioPlayer.playAudio(audioPlayer.currentMedia!);
        }
      }

      // Navigate to MainPanel
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainPanel()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error initializing app: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    return Scaffold(
      backgroundColor:
          isDarkMode ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
      appBar: AppBar(
        backgroundColor:
            isDarkMode
                ? Theme.of(context).appBarTheme.backgroundColor
                : Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 120,
              width: 170,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(),
              child: Transform.scale(
                scale: 1.8,
                child: Image.asset(
                  "images/vibe_logo.png",
                  fit: BoxFit.contain, // Use BoxFit for proper scaling
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.error, size: 50),
                ),
              ),
              // child: Transform.scale(
              //   scale: 1.8,
              //   child: Image.asset(
              //     "images/WhatsApp_Image_2025-06-18_at_5.43.38_PM-removebg-preview.png",
              //     fit: BoxFit.contain, // Use BoxFit for proper scaling
              //     errorBuilder:
              //         (context, error, stackTrace) =>
              //             const Icon(Icons.error, size: 50),
              //   ),
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
