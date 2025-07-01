import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:s_player/features/audio/components/audio_custom_tab.dart';
import 'package:s_player/utilities/constants/app_colors.dart';
import 'package:s_player/utilities/constants/app_icons.dart';
import 'package:path/path.dart' as p;
import 'dart:typed_data';

import '../../../utilities/themes/theme_provider.dart';
import '../../media_list_item.dart';
import '../../state_management/audio_player_provider.dart';
import '../../state_management/media_scranner_provider.dart';
import '../components/favorite_music_highlight_container.dart';
import 'favorite_songs_screen.dart';
import 'filter_song_screen.dart';

class AllAudiosScreen extends StatefulWidget {
  const AllAudiosScreen({super.key});

  @override
  State<AllAudiosScreen> createState() => _AllAudiosScreenState();
}

class _AllAudiosScreenState extends State<AllAudiosScreen> {
  Map<String, dynamic>? _selectedFavorite;
  int favCurrentIndex = 0;
  int allSongCurrentIndex = 0;

  void _playAudio(BuildContext context, String path) {
    final playerProvider = Provider.of<AudioPlayerProvider>(context, listen: false);
    playerProvider.playAudio(path, onComplete: (completedPath) {
      final scannerProvider = Provider.of<MediaScannerProvider>(context, listen: false);
      playerProvider.playNext(scannerProvider.audios.map((e) => e['path'] as String).toList());
    });
  }

  void _removeFavorite(BuildContext context, String path) {
    final scannerProvider = Provider.of<MediaScannerProvider>(context, listen: false);
    scannerProvider.toggleFavorite(path);
    if (_selectedFavorite?['path'] == path) {
      setState(() {
        _selectedFavorite = scannerProvider.favorites.isNotEmpty ? scannerProvider.favorites.first : null;
      });
    }
  }

  void _selectFavorite(Map<String, dynamic> favorite) {
    setState(() {
      _selectedFavorite = favorite;
    });
  }

  void _onAllSongTabClick(int index) {
    setState(() {
      allSongCurrentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scannerProvider = Provider.of<MediaScannerProvider>(context, listen: false);
      if (scannerProvider.favorites.isNotEmpty) {
        setState(() {
          _selectedFavorite = scannerProvider.favorites.first;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context).isDarkMode;
    final scannerProvider = Provider.of<MediaScannerProvider>(context);
    final playerProvider = Provider.of<AudioPlayerProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider ? null : Colors.white,
      appBar: scannerProvider.favorites.isEmpty ? AppBar(
          backgroundColor: themeProvider ? null : Colors.white,
          surfaceTintColor: themeProvider ? Colors.black : Colors.white,
          elevation: 0,
          title: const Text(
              "Audios",
              style: TextStyle()),
          automaticallyImplyLeading: false,
      ): null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            scannerProvider.favorites.isEmpty ? const SizedBox.shrink() : GestureDetector(
              onTap: () {
                if (_selectedFavorite != null) {
                  _playAudio(context, _selectedFavorite!['path']);
                }
              },
              child: Container(
                height: 350,
                width: MediaQuery.of(context).size.width,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(),
                child: Stack(
                  children: [
                    Container(
                      height: 400,
                      width: MediaQuery.of(context).size.width,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(),
                      child: _selectedFavorite?['albumArt'] != null
                          ? Image.memory(
                        _selectedFavorite!['albumArt'] as Uint8List,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          "images/4a543ddc1897e807dfc9c1a356ef1f85.jpg",
                          fit: BoxFit.cover,
                        ),
                      )
                          : Image.asset(
                        "images/4a543ddc1897e807dfc9c1a356ef1f85.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        height: 70,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF121212),
                              blurRadius: 30,
                              spreadRadius: 40,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        height: 70,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: const Color(0xFF121212),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF121212),
                              blurRadius: 30,
                              spreadRadius: 40,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _selectedFavorite == null
                                ? "Chest Course 101"
                                : _selectedFavorite!['title'] ?? p.basename(_selectedFavorite!['path']),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                _selectedFavorite == null
                                    ? "237 Enrolled"
                                    : _selectedFavorite!['artist'] ?? 'Unknown Artist',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                height: 20,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Color(AppColors.primaryColor),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Text(
                                    _selectedFavorite == null ? "Paid" : "Play",
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          if (_selectedFavorite != null)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(AppColors.primaryColor).withOpacity(0.2),
                                    border: Border.all(width: 2, color: Color(AppColors.primaryColor)),
                                  ),
                                  child: _selectedFavorite!['albumArt'] != null
                                      ? ClipOval(
                                    child: Image.memory(
                                      _selectedFavorite!['albumArt'] as Uint8List,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Icon(
                                        Icons.music_note_rounded,
                                        color: Color(AppColors.primaryColor),
                                        size: 18,
                                      ),
                                    ),
                                  )
                                      : Icon(
                                    Icons.music_note_rounded,
                                    color: Color(AppColors.primaryColor),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _selectedFavorite!['artist'] ?? 'Unknown Artist',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Text(
                                      "Artist",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          const SizedBox(height: 5),
                          if (_selectedFavorite == null)
                            const CourseBreakHighlightBreakDown(
                              color: Colors.red,
                              title: "Calories",
                            ),
                          if (_selectedFavorite == null)
                            const CourseBreakHighlightBreakDown(
                              color: Colors.green,
                              title: "54min daily",
                            ),
                          const SizedBox(height: 5),
                          GestureDetector(
                            onTap: () {
                              if (_selectedFavorite != null) {
                                _playAudio(context, _selectedFavorite!['path']);
                              }
                            },
                            child: Container(
                              height: 30,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: Image.asset(AppIcons.playFiledIcon),
                                    ),
                                    Text(
                                      _selectedFavorite == null ? "More Details" : "Play Now",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                scannerProvider.favorites.isEmpty ? const SizedBox.shrink() : const SizedBox(height: 10),
                scannerProvider.favorites.isEmpty ? const SizedBox.shrink() : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Favorite Songs",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FavoriteSongsScreen()),
                          );
                        },
                        child: Text(
                          "See All",
                          style: TextStyle(
                            color: Color(AppColors.primaryColor),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                scannerProvider.favorites.isEmpty ? const SizedBox.shrink() : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (scannerProvider.favorites.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            "No favorite songs yet",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        for (var i = 0; i < scannerProvider.favorites.length; i++)
                          Padding(
                            padding: EdgeInsets.only(
                              left: 10.0,
                              right: scannerProvider.favorites.length - 1 == i ? 10.0 : 0,
                            ),
                            child: GestureDetector(
                              onTap: () => _selectFavorite(scannerProvider.favorites[i]),
                              child: FavoriteMusicHighlightContainer(
                                musicName: scannerProvider.favorites[i]['title'] ??
                                    p.basename(scannerProvider.favorites[i]['path']),
                                artistName: scannerProvider.favorites[i]['artist'] ?? 'Unknown Artist',
                                musicId: scannerProvider.favorites[i]['path'],
                                isPlaying: playerProvider.currentMedia == scannerProvider.favorites[i]['path'],
                                // albumArt: scannerProvider.favorites[i]['albumArt'], // Pass album art
                                onTap: () {
                                  setState(() {
                                    favCurrentIndex = i;
                                  });
                                  _selectFavorite(scannerProvider.favorites[i]);
                                },
                                index: i,
                                currentIndex: favCurrentIndex,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
                scannerProvider.favorites.isEmpty ? const SizedBox.shrink() : const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      AudioCustomTab(
                        title: "All Songs",
                        icon: Icons.music_note_rounded,
                        currentIndex: allSongCurrentIndex,
                        index: 0,
                        onClick: () => _onAllSongTabClick(0),
                      ),
                      AudioCustomTab(
                        title: "Artist",
                        icon: IconlyBroken.profile,
                        currentIndex: allSongCurrentIndex,
                        index: 1,
                        onClick: () => _onAllSongTabClick(1),
                      ),
                      AudioCustomTab(
                        title: "Album",
                        icon: IconlyBold.folder,
                        currentIndex: allSongCurrentIndex,
                        index: 2,
                        onClick: () => _onAllSongTabClick(2),
                      ),
                      AudioCustomTab(
                        title: "Folder",
                        icon: IconlyLight.folder,
                        currentIndex: allSongCurrentIndex,
                        index: 3,
                        onClick: () => _onAllSongTabClick(3),
                      ),
                    ],
                  ),
                ),
                // const SizedBox(height: 10),
                if (scannerProvider.errorMessage != null)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          scannerProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => scannerProvider.pickMediaManually(),
                          child: const Text('Pick Audios Manually'),
                        ),
                        ElevatedButton(
                          onPressed: () => scannerProvider.loadMedia(),
                          child: const Text('Retry Scanning'),
                        ),
                      ],
                    ),
                  )
                else if (scannerProvider.audios.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No audios found'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => scannerProvider.pickMediaManually(),
                          child: const Text('Pick Audios Manually'),
                        ),
                      ],
                    ),
                  )
                else
                  _buildFilteredContent(scannerProvider, playerProvider),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredContent(MediaScannerProvider scannerProvider, AudioPlayerProvider playerProvider) {
    switch (allSongCurrentIndex) {
      case 1: // Artist
        return _buildCategoryList(
          items: scannerProvider.artists,
          title: 'Artists',
          onTap: (artist) => _navigateToFilteredSongs(
            context,
            title: artist,
            songs: scannerProvider.getAudiosByArtist(artist),
          ),
        );
      case 2: // Album
        return _buildCategoryList(
          items: scannerProvider.albums,
          title: 'Albums',
          onTap: (album) => _navigateToFilteredSongs(
            context,
            title: album,
            songs: scannerProvider.getAudiosByAlbum(album),
          ),
        );
      case 3: // Folder
        return _buildCategoryList(
          items: scannerProvider.folders,
          title: 'Folders',
          onTap: (folder) => _navigateToFilteredSongs(
            context,
            title: p.basename(folder),
            songs: scannerProvider.getAudiosByFolder(folder),
          ),
        );
      default: // All Songs
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: scannerProvider.audios.length,
          itemBuilder: (context, index) {
            final song = scannerProvider.audios[index];
            return MediaListItem(
              mediaPath: song['path'],
              isVideo: false,
              title: song['title'],
              artist: song['artist'],
              albumArt: song['albumArt'], // Pass album art to MediaListItem
            );
          },
        );
    }
  }

  Widget _buildCategoryList({
    required List<String> items,
    required String title,
    required Function(String) onTap,
  }) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Color(AppColors.primaryColor).withOpacity(0.2),
            child: Icon(Icons.album, color: Color(AppColors.primaryColor), size: 18),
          ),
          title: Text(item),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onTap(item),
        );
      },
    );
  }

  void _navigateToFilteredSongs(
      BuildContext context, {
        required String title,
        required List<Map<String, dynamic>> songs,
      }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilteredSongsScreen(
          title: title,
          songs: songs,
        ),
      ),
    );
  }
}

class CourseBreakHighlightBreakDown extends StatelessWidget {
  final Color color;
  final String title;

  const CourseBreakHighlightBreakDown({
    super.key,
    required this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}