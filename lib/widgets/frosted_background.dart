import 'dart:ui';
import 'package:flutter/material.dart';

class FrostedBackground extends StatelessWidget {
  final Widget child;
  final double sigma;
  final double opacity;
  
  const FrostedBackground({
    Key? key,
    required this.child,
    this.sigma = 12.0,
    this.opacity = 0.6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        // Background with subtle gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      const Color(0xFF333333),
                      const Color(0xFF555555),
                    ]
                  : [
                      const Color(0xFFF5F5F5),
                      const Color(0xFFE0E0E0),
                    ],
            ),
          ),
        ),
        
        // More transparent frosted glass effect
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