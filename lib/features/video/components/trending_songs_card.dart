import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class TrendingSongsCard extends StatelessWidget {
  const TrendingSongsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          // color: Colors.grey,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset("images/4a543ddc1897e807dfc9c1a356ef1f85.jpg", fit: BoxFit.cover,),
            ),
            const SizedBox(width: 10,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Talk With Meera",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                  ),
                ),
                Text(
                  "ALMA, French Montana - phases",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey
                  ),
                ),
              ],
            ),
            Spacer(),
            Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                shape: BoxShape.circle
              ),
              child: Center(
                child: Icon(IconlyLight.play, color: Colors.black, size: 20,),
              ),
            )
          ],
        ),
      ),
    );
  }
}
