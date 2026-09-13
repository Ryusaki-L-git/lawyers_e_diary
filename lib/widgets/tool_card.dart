import 'package:flutter/material.dart';

import 'app_palette.dart';

class ToolCard extends StatefulWidget {
  const ToolCard({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.colors,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final List<Color> colors;

  @override
  State<ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<ToolCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      lowerBound: 0.96,
      upperBound: 1,
      value: 1,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pressController,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x160B1020),
                blurRadius: 14,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: widget.onTap,
            onTapDown: (_) => _pressController.reverse(),
            onTapUp: (_) => _pressController.forward(),
            onTapCancel: () => _pressController.forward(),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.77),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(widget.icon, size: 19, color: AppPalette.deepTeal),
                  ),
                  const Spacer(),
                  Text(
                    widget.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppPalette.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
