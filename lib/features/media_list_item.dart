import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:s_player/features/state_management/audio_player_provider.dart';
import 'package:s_player/features/state_management/media_scranner_provider.dart';
import 'package:s_player/features/video/screens/play_video_screen.dart';
import 'package:s_player/utilities/constants/app_colors.dart';

import 'audio/components/audio_more_actions_bottom_sheet.dart';
import 'audio/screens/audio_player_screen.dart';

class MediaListItem extends StatefulWidget {
  final String mediaPath;
  final bool isVideo;
  final String? title;
  final String? artist;
  final Uint8List? albumArt;

  const MediaListItem({
    super.key,
    required this.mediaPath,
    required this.isVideo,
    this.title,
    this.artist,
    this.albumArt,
  });

  @override
  State<MediaListItem> createState() => _MediaListItemState();
}

class _MediaListItemState extends State<MediaListItem> {
  void _showAudioMoreActionsBottomSheet(BuildContext context, String title) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => AudioMoreActionsBottomSheet(title: title, isVideo: false,),
    );
  }

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

    return FutureBuilder<bool>(
      future: scannerProvider.isFavorite(widget.mediaPath),
      builder: (context, snapshot) {
        final isFavorite = snapshot.data ?? false;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
          child: MaterialButton(
            onPressed: () {
              if (widget.mediaPath.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid media path')),
                );
                return;
              }
              if (widget.isVideo) {
                playerProvider.playVideo(widget.mediaPath);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const VideoPlayerScreen(),
                  ),
                );
              } else {
                final audioPaths =
                    scannerProvider.audios
                        .map((e) => e['path'] as String?)
                        .where((path) => path != null)
                        .cast<String>()
                        .toList();
                if (audioPaths.contains(widget.mediaPath)) {
                  playerProvider.playAudio(
                    widget.mediaPath,
                    onComplete: (completedPath) {
                      playerProvider.playNext(audioPaths);
                    },
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AudioPlayerScreen(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Audio file not found in library'),
                    ),
                  );
                }
              }
            },
            padding: EdgeInsets.zero,
            child: Container(
              height: 60,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(color: Colors.transparent),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: widget.albumArt != null ? 60 : 50,
                    width: widget.albumArt != null ? 60 : 50,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Color(AppColors.primaryColor).withOpacity(0.2),
                      borderRadius:widget.albumArt != null ? BorderRadius.circular(12,) : null,
                      shape: widget.albumArt == null ? BoxShape.circle : BoxShape.rectangle
                    ),
                    child:
                        widget.albumArt != null
                            ? Image.memory(
                              widget.albumArt!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Icon(
                                    Icons.music_note,
                                    color: Color(AppColors.primaryColor),
                                  ),
                            )
                            : Icon(
                              Icons.music_note,
                              color: Color(AppColors.primaryColor),
                            ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (widget.title ?? widget.mediaPath.split('/').last)
                                      .length >
                                  60
                              ? '${(widget.title ?? widget.mediaPath.split('/').last).substring(0, 60)}...'
                              : (widget.title ??
                                  widget.mediaPath.split('/').last),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                          // maxLines: 1, // Usually not needed if you are manually truncating.
                          // TextOverflow.ellipsis would also work but might not hit exactly 30.
                        ),
                        Text(
                          widget.artist ?? 'Unknown Artist',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed:
                        () => _showAudioMoreActionsBottomSheet(
                          context,
                          "${widget.title}",
                        ),
                    icon: Icon(
                      IconlyLight.category,
                      size: 20,
                      color: Color(AppColors.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
