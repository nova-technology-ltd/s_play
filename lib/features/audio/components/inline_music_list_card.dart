import 'package:flutter/material.dart';
import 'package:s_player/utilities/constants/app_colors.dart';

class InlineMusicListCard extends StatelessWidget {
  final String musicName;
  final String artistName;
  final String musicId;
  final Function(String) onRemove;
  final VoidCallback onTap;
  final bool isPlaying;
  final bool isSelected;

  const InlineMusicListCard({
    super.key,
    required this.musicName,
    required this.artistName,
    required this.musicId,
    required this.onRemove,
    required this.onTap,
    this.isPlaying = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
      child: Container(
        height: 30,
        width: MediaQuery.of(context).size.width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: isPlaying
              ? Color(AppColors.primaryColor).withOpacity(0.2)
              : isSelected
              ? Colors.blue.withOpacity(0.2)
              : null,
        ),
        child: MaterialButton(
          onPressed: onTap,
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            children: [
              Icon(Icons.drag_handle, size: 18, color: Colors.grey),
              const SizedBox(width: 5),
              Expanded(
                flex: 9,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                          color: Color(AppColors.primaryColor).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isPlaying ? Icons.play_arrow : Icons.music_note_rounded,
                          color: Color(AppColors.primaryColor),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Row(
                        children: [
                          Text(
                            musicName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Container(
                              height: 1,
                              width: 10,
                              decoration: BoxDecoration(color: Colors.grey),
                            ),
                          ),
                          Text(
                            artistName,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => onRemove(musicId),
                  child: Icon(Icons.close, size: 18, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}