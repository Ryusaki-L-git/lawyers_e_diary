import 'package:flutter/material.dart';

import '../../../models/team_model.dart';
import '../../../services/team_service.dart';
import '../../../widgets/app_palette.dart';
import '../widgets/team_header.dart';

/// Screen 12 (Owner): Team Chat & Announcements
/// Firm-wide broadcast announcements and multi-conversation team stream.
class TeamChatAnnouncementsScreen extends StatefulWidget {
  const TeamChatAnnouncementsScreen({
    super.key,
    required this.team,
    required this.membership,
  });

  final TeamModel team;
  final TeamMembership membership;

  @override
  State<TeamChatAnnouncementsScreen> createState() =>
      _TeamChatAnnouncementsScreenState();
}

class _TeamChatAnnouncementsScreenState
    extends State<TeamChatAnnouncementsScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isAnnouncement = false;
  bool _isSending = false;

  static const Color _bg = AppPalette.canvas;
  static const Color _black = AppPalette.primaryGreen;
  static const Color _gold = AppPalette.accentGold;

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
      final formattedText = _isAnnouncement ? '📢 ANNOUNCEMENT:\n$text' : text;
      await TeamService.instance.sendMessage(
        teamId: widget.team.id,
        text: formattedText,
        type: _isAnnouncement ? MessageType.system : MessageType.text,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: $e'), backgroundColor: Colors.red),
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
        title: 'Firm Announcements',
        subtitle: '${widget.team.lawFirm} · Broadcast Channel',
        showBack: false,
      ),
      body: Column(
        children: [
          // Stream of messages
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
                              color: _black.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.campaign_outlined, color: _gold, size: 28),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Broadcast Channel',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'serif'),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Post firm notices, hearing schedules, or discuss matters with associates.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Color(0xFF6B665E)),
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
                    final isAnnouncement = msg.text.startsWith('📢');

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.82,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isAnnouncement
                              ? const Color(0xFFFFF8E7)
                              : isMe
                                  ? _black
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isAnnouncement
                                ? _gold.withValues(alpha: 0.5)
                                : isMe
                                    ? Colors.transparent
                                    : const Color(0xFFE5DFD7),
                          ),
                          boxShadow: const [
                            BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: isMe && !isAnnouncement ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (!isMe || isAnnouncement)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    msg.senderName,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isAnnouncement ? const Color(0xFF7A4E00) : _gold,
                                    ),
                                  ),
                                  if (isAnnouncement) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: _gold,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'NOTICE',
                                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            const SizedBox(height: 4),
                            Text(
                              msg.text,
                              style: TextStyle(
                                fontSize: 13.5,
                                color: isAnnouncement
                                    ? const Color(0xFF342319)
                                    : isMe
                                        ? Colors.white
                                        : AppPalette.textPrimary,
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
                                color: isAnnouncement
                                    ? const Color(0xFF946200)
                                    : isMe
                                        ? const Color(0xFF888888)
                                        : const Color(0xFFAAAAAA),
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

          // Message input bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE5DFD7))),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    children: [
                      FilterChip(
                        label: const Text('Broadcast Notice'),
                        selected: _isAnnouncement,
                        onSelected: (val) => setState(() => _isAnnouncement = val),
                        selectedColor: _gold.withValues(alpha: 0.2),
                        checkmarkColor: const Color(0xFF7A4E00),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _isAnnouncement ? const Color(0xFF7A4E00) : const Color(0xFF6B665E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: _isAnnouncement
                                ? 'Post a firm announcement to all counsel…'
                                : 'Type a broadcast message…',
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
                              borderSide: const BorderSide(color: _gold),
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
                            color: _black,
                            shape: BoxShape.circle,
                          ),
                          child: _isSending
                              ? const Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(color: _gold, strokeWidth: 2),
                                  ),
                                )
                              : const Icon(Icons.send_rounded, color: _gold, size: 20),
                        ),
                      ),
                    ],
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

