import 'package:flutter/material.dart';

class CaptureAnimation extends StatefulWidget {
  final bool isTriggered;
  final VoidCallback onAnimationComplete;

  const CaptureAnimation({
    super.key,
    required this.isTriggered,
    required this.onAnimationComplete,
  });

  @override
  State<CaptureAnimation> createState() => _CaptureAnimationState();
}

class _CaptureAnimationState extends State<CaptureAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.9)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 70,
      ),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete();
      }
    });
  }

  @override
  void didUpdateWidget(covariant CaptureAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTriggered && !oldWidget.isTriggered) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        if (_opacityAnimation.value == 0.0) {
          return const SizedBox.shrink();
        }
        return Positioned.fill(
          child: IgnorePointer(
            child: Container(
              color: Colors.white.withOpacity(_opacityAnimation.value),
            ),
          ),
        );
      },
    );
  }
}
