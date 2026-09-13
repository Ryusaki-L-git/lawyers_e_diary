import 'package:flutter/material.dart';

import '../widgets/app_palette.dart';

/// Shared shell for registered legal modules while keeping every dashboard
/// action navigable from day one.
class ModuleLandingScreen extends StatelessWidget {
  const ModuleLandingScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: Color(0xFFE7F0ED),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppPalette.teal, size: 34),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  color: AppPalette.ink,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your $title workspace is ready for the next legal task.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppPalette.mutedInk),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
