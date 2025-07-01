import 'package:flutter/material.dart';
import 'package:s_player/utilities/constants/app_colors.dart';
import 'package:s_player/utilities/constants/app_icons.dart';

class FavoriteMusicHighlightContainer extends StatelessWidget {
  final String musicName;
  final String artistName;
  final String musicId;
  final String? imageUrl; // Optional image URL for album art
  final VoidCallback onTap;
  final bool isPlaying;
  final bool isSelected;
  final int index;
  final int currentIndex;
  final VoidCallback? onLongPress; // For drag-and-drop or additional actions
  final AnimationController? animationController; // For custom animations

  const FavoriteMusicHighlightContainer({
    super.key,
    required this.musicName,
    required this.artistName,
    required this.musicId,
    required this.onTap,
    this.imageUrl,
    this.isPlaying = false,
    this.isSelected = false,
    required this.index,
    required this.currentIndex,
    this.onLongPress,
    this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrent = index == currentIndex;

    // Animation for scale effect when playing or selected
    final scaleAnimation = animationController != null
        ? Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: animationController!,
        curve: Curves.easeInOut,
      ),
    )
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 1.0),
      child: AnimatedBuilder(
        animation: animationController ?? AlwaysStoppedAnimation(1.0),
        builder: (context, child) {
          return Transform.scale(
            scale: scaleAnimation?.value ?? 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onTap,
                  onLongPress: onLongPress,
                  child: Semantics(
                    label: '$musicName by $artistName${isPlaying ? ', currently playing' : ''}',
                    child: Container(
                      width: 80, // Dynamic width for better responsiveness
                      height: 80,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isCurrent
                            ? theme.colorScheme.primary.withOpacity(0.2)
                            : theme.colorScheme.surfaceContainer,
                        border: isCurrent
                            ? Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        )
                            : null,
                        boxShadow: [
                          if (isCurrent || isPlaying)
                            BoxShadow(
                              color: Color(AppColors.primaryColor).withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          isPlaying ? const SizedBox.shrink() : Center(child: Icon(Icons.music_note_rounded, color: Colors.grey,)),
                          if (isPlaying)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(25.0),
                                  child: Image.asset(AppIcons.pauseFilledIcon, color: Colors.white,),
                                ),
                              ),
                            ),
                          // Selected state overlay
                          if (isSelected && !isPlaying)
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}