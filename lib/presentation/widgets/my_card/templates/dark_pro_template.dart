import 'package:flutter/material.dart';

class DarkProTemplate extends StatelessWidget {
  const DarkProTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: Stack(
        children: [
          // Gold dot accent
          Positioned(
            right: 20,
            top: 20,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFF0B31B),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Bottom violet gradient bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 6,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6A3EEB),
                    Color(0xFF9B6EF5),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
