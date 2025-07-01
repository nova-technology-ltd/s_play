import 'package:flutter/material.dart';
import '../../media_list_item.dart';

class FilteredSongsScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> songs;

  const FilteredSongsScreen({
    super.key,
    required this.title,
    required this.songs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: songs.isEmpty
          ? const Center(child: Text('No songs found'))
          : ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return MediaListItem(
            mediaPath: song['path'],
            isVideo: false,
            title: song['title'],
            artist: song['artist'],
          );
        },
      ),
    );
  }
}