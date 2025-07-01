import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utilities/themes/theme_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
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
