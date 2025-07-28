import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AnimatedLogoWidget extends StatefulWidget {
  const AnimatedLogoWidget({Key? key}) : super(key: key);

  @override
  State<AnimatedLogoWidget> createState() => _AnimatedLogoWidgetState();
}

class _AnimatedLogoWidgetState extends State<AnimatedLogoWidget>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _leafController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _leafRotation;

  @override
  void initState() {
    super.initState();

    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Leaf animation controller
    _leafController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo scale animation
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // Logo opacity animation
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Leaf rotation animation
    _leafRotation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _leafController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() {
    _logoController.forward();
    _leafController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _leafController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _leafController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: Opacity(
            opacity: _logoOpacity.value,
            child: Container(
              width: 25.w,
              height: 25.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Transform.rotate(
                  angle: _leafRotation.value,
                  child: CustomIconWidget(
                    iconName: 'eco',
                    size: 15.w,
                    color: AppTheme.lightTheme.colorScheme.surface,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
