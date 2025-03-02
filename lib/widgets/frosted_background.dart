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
    this.opacity = 0.75, // Lighter for a cleaner feel
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        // Simple gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      const Color(0xFF222222), 
                      const Color(0xFF383838),
                    ]
                  : [
                      const Color(0xFFF5F5F5),
                      const Color(0xFFE5E5E5),
                    ],
            ),
          ),
        ),
        
        // Clean, subtle blur
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