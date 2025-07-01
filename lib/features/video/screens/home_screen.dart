import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:s_player/features/video/components/artist_section.dart';
import 'package:s_player/features/video/components/play_list_section.dart';
import 'package:s_player/features/video/components/podcast_section.dart';
import 'package:s_player/features/video/components/trending_songs_section.dart';
import 'package:s_player/utilities/constants/app_colors.dart';

import '../../../utilities/themes/theme_provider.dart';
import '../../media_list_item.dart';
import '../../state_management/media_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context).isDarkMode;
    final provider = Provider.of<MediaProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider ? null : Colors.white,
      appBar: AppBar(
        surfaceTintColor: themeProvider ? Colors.black : Colors.white,
        backgroundColor: themeProvider ? null : Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Row(
            children: [
              Container(
                height: 38,
                width: 38,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Center(
                    child: Container(
                      height: 50,
                      width: 50,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle
                      ),
                      child: Image.asset("images/4a543ddc1897e807dfc9c1a356ef1f85.jpg", fit: BoxFit.cover,),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Hello, Cody Fisher",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  Text(
                    "Good Morning",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        leadingWidth: 180,
        actions: [
          IconButton(onPressed: (){}, icon: Icon(IconlyBold.notification))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                height: 40,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(IconlyLight.search, color: Colors.grey, size: 20,),
                      const SizedBox(width: 10,),
                      Text(
                        "Search",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            //podcast section
            PodcastSection(),
            const SizedBox(height: 25,),
            ArtistSection(),
            const SizedBox(height: 25,),
            PlayListSection(),
            const SizedBox(height: 25,),
            TrendingSongsSection()
          ],
        ),
      ),
    );
  }
}
