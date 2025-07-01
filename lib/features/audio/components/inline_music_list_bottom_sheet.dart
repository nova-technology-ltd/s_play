// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:s_player/features/audio/components/inline_music_list_card.dart';
// import 'package:s_player/utilities/themes/theme_provider.dart';
//
// import '../../state_management/media_provider.dart';
//
// class InlineMusicListBottomSheet extends StatefulWidget {
//   const InlineMusicListBottomSheet({super.key});
//
//   @override
//   State<InlineMusicListBottomSheet> createState() => _InlineMusicListBottomSheetState();
// }
//
// class _InlineMusicListBottomSheetState extends State<InlineMusicListBottomSheet> {
//   void _shuffleAudioList(BuildContext context) {
//     final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
//     setState(() {
//       mediaProvider.audios.shuffle();
//     });
//   }
//   void _removeAudioItem(BuildContext context, String path) {
//     final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
//     setState(() {
//       mediaProvider.audios.remove(path);
//     });
//   }
//   void _playAudio(BuildContext context, String path) {
//     final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
//     mediaProvider.playAudio(path);
//   }
//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context).isDarkMode;
//     final mediaProvider = Provider.of<MediaProvider>(context);
//
//     return Material(
//       color: Colors.transparent,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
//         child: Card(
//           color: themeProvider ? null : Colors.white,
//           elevation: 0,
//           clipBehavior: Clip.antiAlias,
//           child: Container(
//             height: MediaQuery.of(context).size.height * 0.8,
//             width: MediaQuery.of(context).size.width,
//             decoration: BoxDecoration(
//               color: themeProvider ? null : Colors.white,
//             ),
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(left: 10.0, top: 5),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             "Playing Queue",
//                             style: TextStyle(
//                               fontSize: 15,
//                             ),
//                           ),
//                           Text(
//                             " (${mediaProvider.audios.length})",
//                             style: TextStyle(
//                               fontSize: 15,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           IconButton(
//                             onPressed: () => _shuffleAudioList(context),
//                             icon: Icon(Icons.shuffle),
//                             tooltip: 'Shuffle Queue',
//                           ),
//                           IconButton(
//                             onPressed: () {
//                               Navigator.pop(context);
//                             },
//                             icon: Icon(Icons.close),
//                             tooltip: 'Close',
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Expanded(
//                   child: ReorderableListView(
//                     onReorder: (oldIndex, newIndex) {
//                       setState(() {
//                         if (newIndex > oldIndex) {
//                           newIndex -= 1;
//                         }
//                         final item = mediaProvider.audios.removeAt(oldIndex);
//                         mediaProvider.audios.insert(newIndex, item);
//                       });
//                     },
//                     children: [
//                       for (var audioPath in mediaProvider.audios)
//                         InlineMusicListCard(
//                           key: ValueKey(audioPath),
//                           musicName: audioPath.split('/').last,
//                           artistName: 'Unknown Artist', // Replace with metadata if available
//                           musicId: audioPath,
//                           isPlaying: mediaProvider.currentMedia == audioPath,
//                           onRemove: (id) => _removeAudioItem(context, id),
//                           onTap: () => _playAudio(context, audioPath),
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utilities/themes/theme_provider.dart';
import '../../state_management/media_provider.dart';
import 'inline_music_list_card.dart';

class InlineMusicListBottomSheet extends StatefulWidget {
  const InlineMusicListBottomSheet({super.key});

  @override
  State<InlineMusicListBottomSheet> createState() => _InlineMusicListBottomSheetState();
}

class _InlineMusicListBottomSheetState extends State<InlineMusicListBottomSheet> {
  void _shuffleAudioList(BuildContext context) {
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    setState(() {
      final audioList = [...mediaProvider.audios];
      audioList.shuffle();
      mediaProvider.audios = audioList;
    });
  }

  void _removeAudioItem(BuildContext context, String path) {
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    setState(() {
      mediaProvider.audios.removeWhere((audio) => audio['path'] == path);
    });
  }

  void _playAudio(BuildContext context, String path) {
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    mediaProvider.playAudio(path);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context).isDarkMode;
    final mediaProvider = Provider.of<MediaProvider>(context);

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: Card(
          color: themeProvider ? null : Colors.white,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: themeProvider ? null : Colors.white,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Playing Queue",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            " (${mediaProvider.audios.length})",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => _shuffleAudioList(context),
                            icon: Icon(Icons.shuffle),
                            tooltip: 'Shuffle Queue',
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.close),
                            tooltip: 'Close',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ReorderableListView(
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        final item = mediaProvider.audios.removeAt(oldIndex);
                        mediaProvider.audios.insert(newIndex, item);
                      });
                    },
                    children: [
                      for (var audio in mediaProvider.audios)
                        InlineMusicListCard(
                          key: ValueKey(audio['path']),
                          musicName: audio['title'] ?? audio['path'].split('/').last,
                          artistName: audio['artist'] ?? 'Unknown Artist',
                          musicId: audio['path'],
                          isPlaying: mediaProvider.currentMedia == audio['path'],
                          onRemove: (id) => _removeAudioItem(context, id),
                          onTap: () => _playAudio(context, audio['path']),
                        ),
                    ],
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