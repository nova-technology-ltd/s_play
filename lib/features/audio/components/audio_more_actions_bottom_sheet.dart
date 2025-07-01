import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:s_player/features/audio/components/more_Action_quick_action_option_card.dart';
import 'package:s_player/features/audio/components/more_action_option_card.dart';

import '../../../utilities/themes/theme_provider.dart';
import '../../state_management/audio_player_provider.dart';
import '../../state_management/media_scranner_provider.dart';
import '../screens/favorite_songs_screen.dart';
import 'dart:typed_data';


class AudioMoreActionsBottomSheet extends StatefulWidget {
  final String? mediaPath;
  final bool isVideo;
  final String? title;
  final String? artist;
  final Uint8List? albumArt;
  const AudioMoreActionsBottomSheet({super.key,
    this.mediaPath,
    required this.isVideo,
    this.title,
    this.artist,
    this.albumArt,});

  @override
  State<AudioMoreActionsBottomSheet> createState() => _AudioMoreActionsBottomSheetState();
}

class _AudioMoreActionsBottomSheetState extends State<AudioMoreActionsBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final scannerProvider = Provider.of<MediaScannerProvider>(
      context,
      listen: false,
    );
    final playerProvider = Provider.of<AudioPlayerProvider>(
      context,
      listen: false,
    );

    final themeProvider = Provider.of<ThemeProvider>(context).isDarkMode;
    return FutureBuilder<bool>(
        future: scannerProvider.isFavorite("${widget.mediaPath}"),
      builder: (context, snapshot) {
        final isFavorite = snapshot.data ?? false;
        return Material(
          color: Colors.transparent,
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: themeProvider ? null : Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))
            ),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.74,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: themeProvider ? null : Colors.white,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10,),
                      Center(
                        child: Container(
                          height: 5,
                          width: 40,
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(50)
                          ),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Text(
                        "${widget.title}",
                        style: TextStyle(
                            fontSize: 18
                        ),
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MoreActionQuickActionOptionCard(title: "Equalizer", onClick: (){}, iconData: IconlyLight.voice_2),
                          MoreActionQuickActionOptionCard(title: "Timer", onClick: (){}, iconData: IconlyLight.time_circle),
                          MoreActionQuickActionOptionCard(title: "Speed", onClick: (){}, iconData: IconlyLight.star),
                          MoreActionQuickActionOptionCard(title: "Favorite", onClick: () => scannerProvider.toggleFavorite("${widget.mediaPath}"), iconData: isFavorite ? IconlyBold.heart : IconlyLight.heart),
                          MoreActionQuickActionOptionCard(title: "Share", onClick: (){}, iconData: IconlyLight.send),
                        ],
                      ),
                      const SizedBox(height: 15,),
                      MoreActionOptionCard(title: "File Transfer", iconData: IconlyLight.folder, onClick: (){}),
                      MoreActionOptionCard(title: "Favorite", iconData: IconlyLight.heart, onClick: (){Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FavoriteSongsScreen()),
                      );}),
                      MoreActionOptionCard(title: "Feedback", iconData: IconlyLight.message, onClick: (){}),
                      MoreActionOptionCard(title: "Audio Chanel", iconData: IconlyLight.swap, onClick: (){}),
                      MoreActionOptionCard(title: "Add", iconData: Icons.add, onClick: (){}),
                      MoreActionOptionCard(title: "Ringtone", iconData: IconlyLight.notification, onClick: (){}),
                      MoreActionOptionCard(title: "Info", iconData: IconlyLight.info_circle, onClick: (){}),
                      MoreActionOptionCard(title: "Delete", iconData: IconlyLight.delete, onClick: (){}),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );}
    );
  }
}
