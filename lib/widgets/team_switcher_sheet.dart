import 'package:flutter/material.dart';

import '../services/firestore_service.dart';

/// Team Switcher bottom sheet opened via the briefcase icon in Cause List.
class TeamSwitcherSheet extends StatelessWidget {
  const TeamSwitcherSheet({
    super.key,
    required this.selectedMemberId,
    required this.onSelected,
  });

  final String selectedMemberId;
  final ValueChanged<TeamMemberModel?> onSelected;

  static const Color primaryGreen = Color(0xFF1F3D2B);
  static const Color textDark = Color(0xFF1A1A1A);

  static Future<void> show(
    BuildContext context, {
    required String selectedMemberId,
    required ValueChanged<TeamMemberModel?> onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TeamSwitcherSheet(
        selectedMemberId: selectedMemberId,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Switch Counsel / Team',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // "All" Team Option
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: selectedMemberId == 'all'
                      ? primaryGreen.withValues(alpha: 0.1)
                      : const Color(0xFFF7F5F2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.groups_rounded,
                  color: selectedMemberId == 'all' ? primaryGreen : Colors.grey,
                  size: 20,
                ),
              ),
              title: const Text(
                'All Firm Associates',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              trailing: selectedMemberId == 'all'
                  ? const Icon(Icons.check_rounded, color: primaryGreen)
                  : null,
              onTap: () {
                onSelected(null);
                Navigator.pop(context);
              },
            ),
            const Divider(height: 1),

            // Team Members from Firestore
            StreamBuilder<List<TeamMemberModel>>(
              stream: firestoreService.getTeamMembers(),
              builder: (context, snapshot) {
                final members = snapshot.data ?? const [];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: members.map((member) {
                    final isSelected = member.id == selectedMemberId;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryGreen.withValues(alpha: 0.1)
                              : const Color(0xFFF7F5F2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: isSelected ? primaryGreen : Colors.grey,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        member.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? primaryGreen : textDark,
                        ),
                      ),
                      subtitle: Text(
                        member.role,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_rounded, color: primaryGreen)
                          : null,
                      onTap: () {
                        onSelected(member);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
