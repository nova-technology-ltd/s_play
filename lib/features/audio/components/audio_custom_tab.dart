import 'package:flutter/material.dart';
import 'package:s_player/utilities/constants/app_colors.dart';

class AudioCustomTab extends StatelessWidget {
  final String title;
  final IconData icon;
  final int currentIndex;
  final int index;
  final VoidCallback onClick;

  const AudioCustomTab({
    super.key,
    required this.title,
    required this.icon,
    required this.currentIndex,
    required this.index,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    // Check if this tab is selected
    final isSelected = currentIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: GestureDetector(
        onTap: onClick,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut, // Smooth animation curve
          decoration: BoxDecoration(
            color: isSelected ? Color(AppColors.primaryColor) : Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white70,
                size: 18,
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: isSelected ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                firstChild: const SizedBox(width: 0), // Empty when not selected
                secondChild: Padding(
                  padding: const EdgeInsets.only(left: 3.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

