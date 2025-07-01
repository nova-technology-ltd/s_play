import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:s_player/utilities/constants/app_icons.dart';

class CustomBottomAction extends StatelessWidget {
  final String home;
  final String audios;
  final String search;
  final String settings;
  final VoidCallback videosClicked;
  final VoidCallback onAudiosClick;
  final VoidCallback onSearchClick;
  final VoidCallback onSettingsClick;

  const CustomBottomAction({
    super.key,
    required this.home,
    required this.audios,
    required this.search,
    required this.videosClicked,
    required this.onAudiosClick,
    required this.onSearchClick,
    required this.settings,
    required this.onSettingsClick,
  });

  @override
  Widget build(BuildContext context) {
    final mobileView = MediaQuery.of(context).size.width < 600;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 30),
        child: Container(
          height: 55,
          width: mobileView ? MediaQuery.of(context).size.width / 2.5 : 200,
          decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white24, width: 1)
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Expanded(
                //   child: IconButton(
                //     onPressed: videosClicked,
                //     icon: Transform.scale(
                //       scale: 1.2,
                //         child: Image.asset(home == "Home" ? AppIcons.heartFilledIcon : AppIcons.heartOutlinedIcon, color: Colors.white,)),
                //   ),
                // ),
                Expanded(
                  child: IconButton(
                    onPressed: onAudiosClick,
                    icon: Transform.scale(
                        scale: 0.9,
                        child: Image.asset(home == "Audios" ? AppIcons.audiosIconFilled : AppIcons.audiosIconOutlined, color: Colors.white,)),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: onSearchClick,
                    icon: Icon(
                      home == "Search" ? IconlyBold.search : IconlyLight.search,
                      color: Colors.white.withOpacity(0.8),
                      size: 25,
                    ),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: onSettingsClick,
                    icon: Icon(
                      home == "Settings"
                          ? IconlyBold.setting
                          : IconlyLight.setting,
                      color: Colors.white.withOpacity(0.8),
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
