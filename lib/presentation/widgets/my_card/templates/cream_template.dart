import 'package:flutter/material.dart';

class CreamTemplate extends StatelessWidget {
  const CreamTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAF7F2),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 2,
            child: Container(
              color: const Color(0xFF6A3EEB),
            ),
          ),
        ],
      ),
    );
  }
}
