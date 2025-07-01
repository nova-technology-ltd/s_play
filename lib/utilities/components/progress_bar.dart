import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/state_management/media_provider.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<MediaProvider>(context).progress;
    return Stack(
      children: [
        Container(
          height: 10,
          color: Colors.grey[300],
        ),
        FractionallySizedBox(
          widthFactor: progress,
          child: Container(
            height: 10,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}