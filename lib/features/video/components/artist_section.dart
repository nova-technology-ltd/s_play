import 'package:flutter/material.dart';
import 'package:s_player/features/video/components/top_artist_card.dart';

import '../../../utilities/constants/app_colors.dart';

class ArtistSection extends StatefulWidget {
  const ArtistSection({super.key});

  @override
  State<ArtistSection> createState() => _ArtistSectionState();
}

class _ArtistSectionState extends State<ArtistSection> {
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
                "Top Artist",
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
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < 6; i++)
                Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 20.0 : 5, right: i == 5 ? 20 : 5),
                  child: TopArtistCard(),
                )
            ],
          ),
        )
      ],
    );
  }
}
