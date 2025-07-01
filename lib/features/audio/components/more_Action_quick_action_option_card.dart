import 'package:flutter/material.dart';
import 'package:s_player/utilities/constants/app_colors.dart';

class MoreActionQuickActionOptionCard extends StatelessWidget {
  final String title;
  final VoidCallback onClick;
  final IconData iconData;
  const MoreActionQuickActionOptionCard({super.key, required this.title, required this.onClick, required this.iconData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          width: 50,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Color(AppColors.primaryColor).withOpacity(0.08),
            borderRadius: BorderRadius.circular(15)
          ),
          child: MaterialButton(
            padding: EdgeInsets.zero,
            onPressed: onClick, child: Icon(iconData, color: Color(AppColors.primaryColor), size: 20,),),
        ),
        const SizedBox(height: 5,),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400
          ),
        )
      ],
    );
  }
}
