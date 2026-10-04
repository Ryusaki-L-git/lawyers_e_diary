import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../widgets/app_palette.dart';

class AccountSecurityScreen extends StatelessWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: const Text(
          'Security & Data',
          style: TextStyle(
            color: AppPalette.ink,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
          color: AppPalette.ink,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppPalette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Password Reset',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.ink,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Send a password reset email to your registered address.',
                  style: TextStyle(color: AppPalette.mutedInk, fontSize: 13),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () async {
                    final email = user?.email;
                    if (email != null && email.isNotEmpty) {
                      try {
                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(email: email);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Password reset link sent to $email'),
                              backgroundColor: AppPalette.teal,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to send reset link: $e'),
                              backgroundColor: AppPalette.unread,
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Send Reset Link'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppPalette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cloud Data Sync',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.ink,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your legal records, clients, and cause lists are continuously synced with encrypted Cloud Firestore storage.',
                  style: TextStyle(color: AppPalette.mutedInk, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.cloud_done_rounded,
                      color: AppPalette.teal,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Live sync active (${user?.email ?? "Cloud"})',
                      style: const TextStyle(
                        color: AppPalette.teal,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
