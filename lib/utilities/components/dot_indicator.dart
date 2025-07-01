import 'package:flutter/material.dart';

class DotIndicator extends StatelessWidget {
  final bool isActive;
  const DotIndicator({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      width: isActive ? 50 : 10,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(360)
      ),
    );
  }
}
