import 'package:flutter/material.dart';

class AnimatedBanner extends StatelessWidget {
  final bool isVisible;
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AnimatedBanner({
    super.key,
    required this.isVisible,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isVisible,
      child: ClipRect(
        child: AnimatedSlide(
          offset: isVisible ? Offset.zero : const Offset(0, -1),
          duration: duration,
          curve: curve,
          child: child,
        ),
      ),
    );
  }
}
