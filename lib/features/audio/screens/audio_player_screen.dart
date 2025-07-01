import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:s_player/features/audio/components/audio_more_actions_bottom_sheet.dart';
import 'package:s_player/features/state_management/audio_player_provider.dart';
import 'package:s_player/utilities/constants/app_colors.dart';
import 'package:s_player/utilities/constants/app_icons.dart';
import 'package:s_player/utilities/themes/theme_provider.dart';
import 'package:s_player/features/audio/components/inline_music_list_bottom_sheet.dart';

import '../../state_management/media_scranner_provider.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  Timer? _seekDebounceTimer;

  void _showInlineMusicListBottomSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => const InlineMusicListBottomSheet(),
    );
  }

  void _showAudioMoreActionsBottomSheet(BuildContext context, String title) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => AudioMoreActionsBottomSheet(title: title, mediaPath: '', isVideo: false,),
    );
  }

  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context).isDarkMode;
    final playerProvider = Provider.of<AudioPlayerProvider>(context);
    final scannerProvider = Provider.of<MediaScannerProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final currentMedia = playerProvider.currentMedia;
    final audioInfo = scannerProvider.audios.firstWhere(
      (audio) => audio['path'] == currentMedia,
      orElse:
          () => {
            'title': currentMedia?.split('/').last ?? 'Unknown Track',
            'artist': 'Unknown Artist',
          },
    );
    final audioTitle = audioInfo['title'] as String;
    final audioArtist = audioInfo['artist'] as String;
    final audioCover =
        audioInfo['albumArt'] is Uint8List
            ? audioInfo['albumArt'] as Uint8List
            : null;
    return Scaffold(
      backgroundColor: themeProvider ? null : Colors.white,
      appBar: AppBar(
        backgroundColor: themeProvider ? null : Colors.white,
        surfaceTintColor: themeProvider ? Colors.black : Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themeProvider ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed:
                currentMedia != null
                    ? () =>
                        _showAudioMoreActionsBottomSheet(context, audioTitle)
                    : null,
            icon: const Icon(IconlyLight.category),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child:
                    audioCover != null
                        ? Container(
                          height: 300,
                          width: screenWidth,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.transparent,
                          ),
                          child: Image.memory(
                            audioCover,
                            // No need for ! since audioCover is now guaranteed Uint8List
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Icon(
                                  Icons.music_note,
                                  color: Color(AppColors.primaryColor),
                                ),
                          ),
                        )
                        : Container(
                          height: 300,
                          width: screenWidth,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.transparent,
                          ),
                          child: Image.asset(
                            "images/3cee6d295160f53a72efa01ecf94dac0.jpg",
                            // Fixed potential typo in filename
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Icon(
                                  Icons.music_note,
                                  size: 100,
                                  color:
                                      themeProvider
                                          ? Colors.white
                                          : Colors.black,
                                ),
                          ),
                        ),
              ),
              const Spacer(),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              audioTitle,
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 24,
                                color:
                                    themeProvider ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              audioArtist,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    themeProvider
                                        ? Colors.grey
                                        : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder<bool>(
                        future: scannerProvider.isFavorite(currentMedia ?? ''),
                        builder: (context, snapshot) {
                          final isFavorite = snapshot.data ?? false;
                          return IconButton(
                            icon: SizedBox(
                              height: 28,
                              width: 28,
                              child: Image.asset(
                                isFavorite
                                    ? AppIcons.heartFilledIcon
                                    : AppIcons.heartOutlinedIcon,
                                color:
                                    themeProvider ? Colors.white : Colors.black,
                              ),
                            ),
                            onPressed:
                                currentMedia != null
                                    ? () => scannerProvider.toggleFavorite(
                                      currentMedia,
                                    )
                                    : null,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Column(
                    children: [
                      GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          if (playerProvider.totalDuration.inMilliseconds == 0)
                            return;
                          final barWidth = screenWidth - 32;
                          final dragPosition = details.localPosition.dx.clamp(
                            0.0,
                            barWidth,
                          );
                          final progress = dragPosition / barWidth;
                          final seekPosition =
                              playerProvider.totalDuration * progress;
                          _seekDebounceTimer?.cancel();
                          _seekDebounceTimer = Timer(
                            const Duration(milliseconds: 100),
                            () => playerProvider.seekTo(seekPosition),
                          );
                        },
                        onTapDown: (details) {
                          if (playerProvider.totalDuration.inMilliseconds == 0)
                            return;
                          final barWidth = screenWidth - 32;
                          final tapPosition = details.localPosition.dx.clamp(
                            0.0,
                            barWidth,
                          );
                          final progress = tapPosition / barWidth;
                          final seekPosition =
                              playerProvider.totalDuration * progress;
                          _seekDebounceTimer?.cancel();
                          _seekDebounceTimer = Timer(
                            const Duration(milliseconds: 100),
                            () => playerProvider.seekTo(seekPosition),
                          );
                        },
                        child: Container(
                          height: 12,
                          width: double.infinity,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  height: 12,
                                  width:
                                      screenWidth *
                                      playerProvider.progress.clamp(0.0, 1.0),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: Color(AppColors.primaryColor),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(playerProvider.currentPosition),
                            style: TextStyle(
                              color:
                                  themeProvider ? Colors.white : Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _formatDuration(playerProvider.totalDuration),
                            style: TextStyle(
                              color:
                                  themeProvider ? Colors.white : Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: SizedBox(
                          height: playerProvider.repeatSong ? 25 : 23,
                          width: playerProvider.repeatSong ? 25 : 23,
                          child: Image.asset(
                            playerProvider.repeatSong
                                ? AppIcons.repeatOnceIcon
                                : AppIcons.repeatIcon,
                            color: themeProvider ? Colors.white : Colors.black,
                          ),
                        ),
                        onPressed: () {
                          playerProvider.repeatSong =
                              !playerProvider.repeatSong;
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: SizedBox(
                              height: 28,
                              width: 28,
                              child: Image.asset(
                                AppIcons.playPrevFilledIcon,
                                color:
                                    themeProvider ? Colors.white : Colors.black,
                              ),
                            ),
                            onPressed: () {
                              final audioPaths =
                                  scannerProvider.audios
                                      .map((e) => e['path'] as String?)
                                      .where((path) => path != null)
                                      .cast<String>()
                                      .toList();
                              playerProvider.playPrevious(audioPaths);
                            },
                          ),
                          IconButton(
                            icon: SizedBox(
                              height: 28,
                              width: 28,
                              child: Image.asset(
                                playerProvider.isPlaying
                                    ? AppIcons.pauseFilledIcon
                                    : AppIcons.playFiledIcon,
                                color:
                                    themeProvider ? Colors.white : Colors.black,
                              ),
                            ),
                            onPressed: () {
                              if (playerProvider.isPlaying) {
                                playerProvider.pause();
                              } else {
                                playerProvider.resume();
                              }
                            },
                          ),
                          IconButton(
                            icon: SizedBox(
                              height: 28,
                              width: 28,
                              child: Image.asset(
                                AppIcons.playNextFilledIcon,
                                color:
                                    themeProvider ? Colors.white : Colors.black,
                              ),
                            ),
                            onPressed: () {
                              final audioPaths =
                                  scannerProvider.audios
                                      .map((e) => e['path'] as String?)
                                      .where((path) => path != null)
                                      .cast<String>()
                                      .toList();
                              playerProvider.playNext(audioPaths);
                            },
                          ),
                        ],
                      ),
                      IconButton(
                        icon: SizedBox(
                          height: 27,
                          width: 27,
                          child: Image.asset(
                            AppIcons.playList,
                            color: themeProvider ? Colors.white : Colors.black,
                          ),
                        ),
                        onPressed:
                            () => _showInlineMusicListBottomSheet(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _seekDebounceTimer?.cancel();
    super.dispose();
  }
}
