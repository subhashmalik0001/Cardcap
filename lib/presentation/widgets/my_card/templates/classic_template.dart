import 'package:flutter/material.dart';

class ClassicTemplate extends StatelessWidget {
  const ClassicTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 8,
            child: Container(
              color: const Color(0xFF6A3EEB),
            ),
          ),
        ],
      ),
    );
  }
}
