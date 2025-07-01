import 'package:flutter/material.dart';
import 'package:s_player/utilities/components/dot_indicator.dart';

import '../../../utilities/constants/app_colors.dart';

class PlayListSection extends StatefulWidget {
  const PlayListSection({super.key});

  @override
  State<PlayListSection> createState() => _PlayListSectionState();
}

class _PlayListSectionState extends State<PlayListSection> {
  int currentCard = 0;
  final PageController _pageController = PageController(initialPage: 0);

  void _onPageSwipe(int index) {
    setState(() {
      currentCard = index;
    });
  }

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
                "Playlists",
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
        SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: 5,
            controller: _pageController,
            onPageChanged: _onPageSwipe,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: Image.asset("images/3cee6d295160f53a72efa01ecf94dac0.jpg", fit: BoxFit.cover,),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 15,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 5; i++)
              if (currentCard == i)
                DotIndicator(isActive: true)
              else
                DotIndicator(isActive: false),
          ],
        ),
      ],
    );
  }
}
