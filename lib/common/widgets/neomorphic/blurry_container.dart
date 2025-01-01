import 'dart:ui';
import 'package:flutter/material.dart';

class BlurryGrainyContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double grainOpacity;
  final BorderRadius borderRadius;

  const BlurryGrainyContainer({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.grainOpacity = 0.1,
    this.borderRadius = const BorderRadius.all(Radius.circular(0)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        children: [
          child,
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(grainOpacity),
              backgroundBlendMode: BlendMode.overlay,
            ),
          ),
        ],
      ),
    );
  }
}
