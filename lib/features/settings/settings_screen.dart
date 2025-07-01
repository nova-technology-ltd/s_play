import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utilities/themes/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      backgroundColor: themeProvider ? null : Colors.white,
      appBar: AppBar(
        backgroundColor: themeProvider ? null : Colors.white,
        surfaceTintColor: themeProvider ? Colors.black : Colors.white,
        automaticallyImplyLeading: false,
      ),
    );
  }
}
