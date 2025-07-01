import 'package:flutter/material.dart';
import 'package:s_player/features/video/components/trending_songs_card.dart';

import '../../../utilities/constants/app_colors.dart';

class TrendingSongsSection extends StatefulWidget {
  const TrendingSongsSection({super.key});

  @override
  State<TrendingSongsSection> createState() => _TrendingSongsSectionState();
}

class _TrendingSongsSectionState extends State<TrendingSongsSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Trending Songs",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400
                ),
              ),
              Text(
                "See All",
                style: TextStyle(
                    fontSize: 12,
                    color: Color(AppColors.primaryColor)
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10,),
        SingleChildScrollView(
          child: Column(
            children: [
              for (int i = 0; i < 6; i++)
                TrendingSongsCard()
            ],
          ),
        )
      ],
    );
  }
}
