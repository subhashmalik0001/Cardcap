import 'package:flutter/material.dart';

class SplitTemplate extends StatelessWidget {
  const SplitTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: const Color(0xFF6A3EEB),
            ),
          ),
          const Expanded(
            flex: 1,
            child: SizedBox(),
          ),
        ],
      ),
    );
  }
}
