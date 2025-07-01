import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:s_player/features/audio/screens/all_audios_screen.dart';
import 'package:s_player/features/search/search_screen.dart';
import 'package:s_player/features/settings/settings_screen.dart';
import 'package:s_player/features/video/screens/home_screen.dart';
import 'package:s_player/utilities/themes/theme_provider.dart';

import 'custom_bottom_action.dart';

class MainPanel extends StatefulWidget {
  const MainPanel({super.key});

  @override
  State<MainPanel> createState() => _MainPanelState();
}

class _MainPanelState extends State<MainPanel> {
  late Offset _offset = const Offset(0, 0);
  String selectedOption = "Home";
  int activeScreen = 0;

  final screens = [
    // const HomeScreen(),
    const AllAudiosScreen(),
    const SearchScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      setState(() {
        _offset = Offset(
          (screenSize.width - 100) / 2.6,
          screenSize.height - 80,
        );
      });
    });
  }

  Widget _currentScreen = const HomeScreen();
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context).isDarkMode;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: themeProvider ? null : Colors.white,
              body: screens[activeScreen],
            ),
            if (_offset != null)
              Positioned(
                left: _offset.dx,
                top: _offset.dy,
                child: Draggable(
                  feedback: CustomBottomAction(
                    home: selectedOption,
                    audios: selectedOption,
                    search: selectedOption,
                    videosClicked: () {},
                    onAudiosClick: () {},
                    onSearchClick: () {},
                    settings: selectedOption,
                    onSettingsClick: () {},
                  ),
                  child: CustomBottomAction(
                    home: selectedOption,
                    audios: selectedOption,
                    search: selectedOption,
                    videosClicked: () {
                      setState(() {
                        selectedOption = "Home";
                        activeScreen = 0;
                      });
                    },
                    onAudiosClick: () {
                      setState(() {
                        selectedOption = "Audios";
                        activeScreen = 1;
                      });
                    },
                    onSearchClick: () {
                      setState(() {
                        selectedOption = "Search";
                        activeScreen = 2;
                      });
                    },
                    settings: selectedOption,
                    onSettingsClick: () {
                      setState(() {
                        selectedOption = "Settings";
                        activeScreen = 3;
                      });
                    },
                  ),
                  onDragEnd: (details) {
                    setState(() {
                      double adjust = MediaQuery.of(context).size.height -
                          constraints.maxHeight;
                      _offset =
                          Offset(details.offset.dx, details.offset.dy - adjust);
                    });
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}