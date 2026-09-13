import 'package:flutter/material.dart';

class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.animation,
    required this.child,
    this.beginOffset = const Offset(0, 0.12),
  });

  final Animation<double> animation;
  final Widget child;
  final Offset beginOffset;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, animatedChild) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(
              0,
              beginOffset.dy * 48 * (1 - animation.value),
            ),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }
}
