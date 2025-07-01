import 'package:flutter/material.dart';

class MoreActionOptionCard extends StatelessWidget {
  final String title;
  final IconData iconData;
  final VoidCallback onClick;
  const MoreActionOptionCard({super.key, required this.title, required this.iconData, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        height: 40,
        width: MediaQuery.of(context).size.width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7)
        ),
        child: MaterialButton(
          padding: EdgeInsets.symmetric(horizontal: 5),
          onPressed: onClick, child: Row(
          children: [
            Icon(iconData), const SizedBox(width: 10,),

            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400
              ),
            )
          ],
        ),),
      ),
    );
  }
}
