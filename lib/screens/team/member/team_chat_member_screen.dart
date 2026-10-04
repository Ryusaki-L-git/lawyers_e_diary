import 'package:flutter/material.dart';

import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';

/// Screen 9: Team Chat (Member View)
/// Live production chat stream with messages and active participation.
class TeamChatMemberScreen extends StatefulWidget {
  const TeamChatMemberScreen({
    super.key,
    required this.team,
    required this.membership,
  });

  final TeamModel team;
  final TeamMembership membership;

  @override
  State<TeamChatMemberScreen> createState() => _TeamChatMemberScreenState();
}

class _TeamChatMemberScreenState extends State<TeamChatMemberScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  static const Color _bg = AppPalette.canvas;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() => _isSending = true);

    try {
      await TeamService.instance.sendMessage(
        teamId: widget.team.id,
        text: text,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: $e'), backgroundColor: AppPalette.unread),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: TeamHeader(
        title: 'Team Channel',
        subtitle: '${widget.team.lawFirm} · ${widget.team.name}',
        showBack: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<TeamMessage>>(
              stream: TeamService.instance.watchMessages(widget.team.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppPalette.primaryGreen.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.chat_bubble_outline_rounded, color: AppPalette.primaryGreen, size: 28),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Chamber Channel',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'serif', color: AppPalette.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Start a discussion or share case updates with counsel.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: AppPalette.textMuted),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == widget.membership.userId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? AppPalette.primaryGreen : AppPalette.cardBackground,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                          ),
                          border: isMe ? null : Border.all(color: AppPalette.borderLight),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (!isMe) ...[
                              Text(
                                msg.senderName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppPalette.accentGold,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            Text(
                              msg.text,
                              style: TextStyle(
                                fontSize: 13.5,
                                color: isMe ? AppPalette.cardBackground : AppPalette.textPrimary,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg.sentAt != null
                                  ? '${msg.sentAt!.hour.toString().padLeft(2, '0')}:${msg.sentAt!.minute.toString().padLeft(2, '0')}'
                                  : '',
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe ? AppPalette.cardBackground.withValues(alpha: 0.75) : AppPalette.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: const BoxDecoration(
              color: AppPalette.cardBackground,
              border: Border(top: BorderSide(color: AppPalette.borderLight)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Type a message to team…',
                        hintStyle: const TextStyle(fontSize: 13, color: AppPalette.textMuted),
                        filled: true,
                        fillColor: AppPalette.canvas,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppPalette.borderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppPalette.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppPalette.primaryGreen),
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _isSending ? null : _sendMessage,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppPalette.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: _isSending
                          ? const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: AppPalette.cardBackground, strokeWidth: 2),
                              ),
                            )
                          : const Icon(Icons.send_rounded, color: AppPalette.cardBackground, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

