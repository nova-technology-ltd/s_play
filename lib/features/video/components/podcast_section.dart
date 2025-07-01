import 'package:flutter/material.dart';
import 'package:s_player/features/video/components/podcast_card.dart';
import 'package:s_player/utilities/constants/app_colors.dart';

class PodcastSection extends StatefulWidget {
  const PodcastSection({super.key});

  @override
  State<PodcastSection> createState() => _PodcastSectionState();
}

class _PodcastSectionState extends State<PodcastSection> {
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
                "Podcast For You",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500
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
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < 6; i++)
                Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 30.0 : 5, right: i == 5 ? 30 : 5),
                  child: PodcastCard(),
                )
            ],
          ),
        )
      ],
    );
  }
}
