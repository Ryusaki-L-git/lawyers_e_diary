import 'package:flutter/material.dart';

import 'app_palette.dart';

class DraftingCard extends StatelessWidget {
  const DraftingCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFCF5), Color(0xFFF5E8C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFE4C77F)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x28C89D4D),
            blurRadius: 28,
            spreadRadius: 1,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: AppPalette.teal,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: Colors.white,
                    size: 29,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Drafting Studio',
                        style: TextStyle(
                          color: AppPalette.ink,
                          fontFamily: 'serif',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Create legal drafts instantly with Juris AI',
                        style: TextStyle(
                          color: AppPalette.mutedInk,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 15),
                      FilledButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                        label: const Text('Start Drafting'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppPalette.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
