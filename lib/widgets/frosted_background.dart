import 'dart:ui';
import 'package:flutter/material.dart';

class FrostedBackground extends StatelessWidget {
  final Widget child;
  final double sigma;
  final double opacity;
  
  const FrostedBackground({
    Key? key,
    required this.child,
    this.sigma = 10.0,
    this.opacity = 0.8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image or color could be added here
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.background,
                Theme.of(context).colorScheme.background.withOpacity(0.8),
              ],
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background.withOpacity(opacity),
            ),
            child: child,
          ),
        ),
      ],
    );
  }
} 