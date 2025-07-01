import 'package:flutter/material.dart';

class TopArtistCard extends StatefulWidget {
  const TopArtistCard({super.key});

  @override
  State<TopArtistCard> createState() => _TopArtistCardState();
}

class _TopArtistCardState extends State<TopArtistCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 70,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle
      ),
      child: Image.asset("images/4a543ddc1897e807dfc9c1a356ef1f85.jpg", fit: BoxFit.cover,),
    );
  }
}
