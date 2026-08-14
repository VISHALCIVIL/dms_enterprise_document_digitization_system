import 'package:flutter/material.dart';
import '../theme/stitch_colors.dart';

class LaserScanOverlay extends StatefulWidget {
  final Widget child;

  const LaserScanOverlay({super.key, required this.child});

  @override
  State<LaserScanOverlay> createState() => _LaserScanOverlayState();
}

class _LaserScanOverlayState extends State<LaserScanOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Positioned(
              top: MediaQuery.of(context).size.height * 0.4 * _animation.value,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: StitchColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: StitchColors.primary.withValues(alpha: 0.8),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
