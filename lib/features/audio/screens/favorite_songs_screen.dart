import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:s_player/features/audio/components/inline_music_list_card.dart';
import 'package:s_player/utilities/themes/theme_provider.dart';

import '../../../utilities/database/database_helper.dart';
import '../../state_management/media_provider.dart';

class FavoriteSongsScreen extends StatefulWidget {
  const FavoriteSongsScreen({super.key});

  @override
  State<FavoriteSongsScreen> createState() => _FavoriteSongsScreenState();
}

class _FavoriteSongsScreenState extends State<FavoriteSongsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'added_at';
  bool _ascending = false;
  bool _isSelectionMode = false;
  Set<String> _selectedSongs = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  void _playAudio(BuildContext context, String path) {
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    mediaProvider.playAudio(path);
  }

  void _removeFavorite(BuildContext context, String path) {
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    mediaProvider.toggleFavorite(path);
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedSongs.clear();
    });
  }

  void _toggleSongSelection(String path) {
    setState(() {
      if (_selectedSongs.contains(path)) {
        _selectedSongs.remove(path);
      } else {
        _selectedSongs.add(path);
      }
    });
  }

  void _deleteSelectedSongs(BuildContext context) async {
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    for (var path in _selectedSongs) {
      await mediaProvider.toggleFavorite(path);
    }
    setState(() {
      _isSelectionMode = false;
      _selectedSongs.clear();
    });
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Sort by Title'),
                onTap: () {
                  setState(() {
                    _sortBy = 'title';
                    _ascending = true;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Sort by Artist'),
                onTap: () {
                  setState(() {
                    _sortBy = 'artist';
                    _ascending = true;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Sort by Added Date'),
                onTap: () {
                  setState(() {
                    _sortBy = 'added_at';
                    _ascending = false;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Sort by Duration'),
                onTap: () {
                  setState(() {
                    _sortBy = 'duration';
                    _ascending = true;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Toggle Ascending/Descending'),
                onTap: () {
                  setState(() {
                    _ascending = !_ascending;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context).isDarkMode;
    final mediaProvider = Provider.of<MediaProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider ? null : Colors.white,
      appBar: AppBar(
        backgroundColor: themeProvider ? null : Colors.white,
        surfaceTintColor: themeProvider ? Colors.black : Colors.white,
        title: Text(
          'Favorite Songs (${mediaProvider.favorites.length})',
          style: TextStyle(
            color: themeProvider ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themeProvider ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteSelectedSongs(context),
            ),
          IconButton(
            icon: Icon(_isSelectionMode ? Icons.cancel : Icons.select_all),
            onPressed: _toggleSelectionMode,
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () => _showSortOptions(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search favorites...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: themeProvider ? Colors.grey[800] : Colors.grey[200],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseHelper.instance.getFavorites(
                    sortBy: _sortBy,
                    ascending: _ascending,
                    searchQuery: _searchController.text,
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final favorites = snapshot.data!;
                    if (favorites.isEmpty) {
                      return Center(
                        child: Text(
                          'No favorite songs yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: themeProvider ? Colors.grey : Colors.grey[600],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final favorite = favorites[index];
                        final path = favorite['path'] as String;
                        return GestureDetector(
                          onLongPress: () => _toggleSongSelection(path),
                          child: InlineMusicListCard(
                            key: ValueKey(path),
                            musicName: favorite['title'] ?? path.split('/').last,
                            artistName: favorite['artist'] ?? 'Unknown Artist',
                            musicId: path,
                            isPlaying: mediaProvider.currentMedia == path,
                            onRemove: (id) => _removeFavorite(context, id),
                            onTap: () => _playAudio(context, path),
                            isSelected: _isSelectionMode && _selectedSongs.contains(path),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}