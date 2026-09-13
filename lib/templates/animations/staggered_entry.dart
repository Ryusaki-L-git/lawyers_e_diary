import 'package:flutter/material.dart';

class StaggeredEntry extends StatelessWidget {
  const StaggeredEntry({
    super.key,
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final offset = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(animation);

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: offset,
        child: child,
      ),
    );
  }
}

class StaggeredEntryController {
  StaggeredEntryController({
    required TickerProvider vsync,
    int itemCount = 9,
    Duration duration = const Duration(milliseconds: 1000),
  }) : controller = AnimationController(vsync: vsync, duration: duration),
       animations = <Animation<double>>[] {
    animations.addAll(List<Animation<double>>.generate(itemCount, (index) {
      final start = 0.04 + (index * 0.07);
      return CurvedAnimation(
        parent: controller,
        curve: Interval(start, start + 0.34, curve: Curves.easeOutCubic),
      );
    }));
  }

  final AnimationController controller;
  final List<Animation<double>> animations;

  void dispose() => controller.dispose();
}
