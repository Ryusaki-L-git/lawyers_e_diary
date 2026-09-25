import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/subscription_service.dart';
import '../widgets/app_palette.dart';
import '../widgets/home_bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.simulateNewNotification = true,
  });

  final bool simulateNewNotification;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _templateTitleKey = 'home_template_title';
  static const _templateSelectionKey = 'home_template_selection';
  static const _templateSelectedKey = 'home_template_was_selected';

  bool _hasUnreadNotifications = false;
  String _templateTitle = 'Workspace';
  String? _templateSelection;

  @override
  void initState() {
    super.initState();
    _hasUnreadNotifications = widget.simulateNewNotification;
    _restoreTemplatePreference();
  }

  Future<void> _restoreTemplatePreference() async {
    final preferences = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _templateTitle =
          preferences.getString(_templateTitleKey) ?? 'Workspace';
      _templateSelection =
          preferences.getString(_templateSelectionKey);
    });
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.simulateNewNotification &&
        !oldWidget.simulateNewNotification) {
      setState(() => _hasUnreadNotifications = true);
    }
  }

  void _openRoute(String route) {
    Navigator.of(context).pushNamed(route);
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).pushNamed('/notifications');

    if (mounted && _hasUnreadNotifications) {
      setState(() => _hasUnreadNotifications = false);
    }
  }

  Future<void> _editTemplateTitle() async {
    final controller = TextEditingController(
      text: _templateTitle,
    );

    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _HomeColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(
              color: _HomeColors.border,
            ),
          ),
          title: const Text(
            'Rename workspace',
            style: TextStyle(
              color: _HomeColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontFamily: 'serif',
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 32,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(
              color: _HomeColors.textPrimary,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Workspace',
              hintStyle: const TextStyle(
                color: _HomeColors.textMuted,
              ),
              filled: true,
              fillColor: _HomeColors.surfaceSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: _HomeColors.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: _HomeColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: _HomeColors.primaryGreen,
                  width: 1.2,
                ),
              ),
            ),
            onSubmitted: (value) {
              Navigator.pop(dialogContext, value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: _HomeColors.textMuted,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _HomeColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  controller.text,
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    final value = title?.trim();

    if (value == null || value.isEmpty || !mounted) return;

    setState(() => _templateTitle = value);

    final preferences =
        await SharedPreferences.getInstance();

    await preferences.setString(
      _templateTitleKey,
      value,
    );
  }

  Future<void> _handleTemplateTap() async {
    final preferences =
        await SharedPreferences.getInstance();

    final hasSelectedBefore =
        preferences.getBool(_templateSelectedKey) ?? false;

    if (!hasSelectedBefore) {
      if (!mounted) return;

      final selection =
          await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (sheetContext) {
          return _TemplatePicker(
            onSelected: (value) {
              Navigator.pop(sheetContext, value);
            },
          );
        },
      );

      if (selection == null || !mounted) return;

      setState(() {
        _templateSelection = selection;
        _templateTitle = selection;
      });

      await preferences.setBool(
        _templateSelectedKey,
        true,
      );

      await preferences.setString(
        _templateSelectionKey,
        selection,
      );

      await preferences.setString(
        _templateTitleKey,
        selection,
      );

      return;
    }

    switch (_templateSelection) {
      case 'Daily Cases':
        _openRoute('/cases');
        return;

      case 'Legal Research':
        _openRoute('/juris');
        return;

      default:
        _openRoute('/profile');
        return;
    }
  }

  String _displayName(User? user) {
    final displayName = user?.displayName?.trim();

    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final emailPrefix =
        user?.email?.split('@').first.trim();

    if (emailPrefix != null && emailPrefix.isNotEmpty) {
      return emailPrefix[0].toUpperCase() +
          emailPrefix.substring(1);
    }

    return 'Counsel';
  }

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _todayLabel() {
    final now = DateTime.now();

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return '${weekdays[now.weekday - 1]}, '
        '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = _displayName(user);

    return Scaffold(
      backgroundColor: _HomeColors.background,
      drawer: _HomeDrawer(
        userName: userName,
        onNavigate: _openRoute,
      ),
      bottomNavigationBar: HomeBottomNavigation(
        currentIndex: 0,
        onNavigate: _openRoute,
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 480,
            ),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    18,
                    20,
                    32,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _TopBar(
                        hasUnreadNotifications:
                            _hasUnreadNotifications,
                        onNotifications:
                            _openNotifications,
                        onMenu: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),

                      const SizedBox(height: 28),

                      _HeroHeader(
                        greeting: _greeting(),
                        userName: userName,
                        date: _todayLabel(),
                      ),

                      const SizedBox(height: 28),

                      _QuickActions(
                        onRoute: _openRoute,
                      ),

                      const SizedBox(height: 30),

                      _TodaySchedule(
                        userId: user?.uid,
                        onViewCalendar: () =>
                            _openRoute('/calendar'),
                      ),

                      const SizedBox(height: 22),

                      _WorkspaceSection(
                        title: _templateTitle,
                        onEdit: _editTemplateTitle,
                        child: _buildWorkspaceCard(),
                      ),

                      const SizedBox(height: 22),

                      _RemindersSection(
                        onViewAll: () =>
                            _openRoute('/reminders'),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkspaceCard() {
    switch (_templateSelection) {
      case 'Daily Cases':
        return _WorkspaceCard(
          icon: Icons.calendar_today_rounded,
          eyebrow: 'CASE WORKSPACE',
          title: 'Daily Cases',
          description:
              'Review and manage your active case diary.',
          actionLabel: 'Open Cases',
          onTap: () => _openRoute('/cases'),
        );

      case 'Legal Research':
        return _WorkspaceCard(
          icon: Icons.auto_stories_rounded,
          eyebrow: 'RESEARCH WORKSPACE',
          title: 'Legal Research',
          description:
              'Continue your work in Drafting Studio.',
          actionLabel: 'Open Juris',
          onTap: () => _openRoute('/juris'),
        );

      case 'Custom':
        return _WorkspaceCard(
          icon: Icons.dashboard_customize_outlined,
          eyebrow: 'PERSONAL WORKSPACE',
          title: 'Custom Workspace',
          description:
              'Your personalized legal workspace.',
          actionLabel: 'Open Profile',
          onTap: () => _openRoute('/profile'),
        );

      default:
        return _WorkspaceCard(
          icon: Icons.add_rounded,
          eyebrow: 'PERSONALIZE',
          title: 'Build your workspace',
          description:
              'Choose the tools you use most and make Home yours.',
          actionLabel: 'Customize',
          onTap: _handleTemplateTap,
        );
    }
  }
}

// =============================================================================
// TOP BAR
// =============================================================================

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.hasUnreadNotifications,
    required this.onNotifications,
    required this.onMenu,
  });

  final bool hasUnreadNotifications;
  final VoidCallback onNotifications;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Builder(
          builder: (context) {
            return _HeaderButton(
              icon: Icons.menu_rounded,
              tooltip: 'Menu',
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            _HeaderButton(
              icon: Icons.notifications_none_rounded,
              tooltip: 'Notifications',
              onTap: onNotifications,
            ),
            if (hasUnreadNotifications)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _HomeColors.accentGold,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _HomeColors.background,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: _HomeColors.surface,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: _HomeColors.border,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: _HomeColors.primaryGreen,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// HERO
// =============================================================================

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.greeting,
    required this.userName,
    required this.date,
  });

  final String greeting;
  final String userName;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting.toUpperCase(),
          style: const TextStyle(
            color: _HomeColors.accentGold,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'Adv. $userName',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _HomeColors.textPrimary,
            fontSize: 31,
            fontWeight: FontWeight.w700,
            fontFamily: 'serif',
            letterSpacing: -0.8,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          date,
          style: const TextStyle(
            color: _HomeColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// QUICK ACTIONS
// =============================================================================

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onRoute,
  });

  final ValueChanged<String> onRoute;

  // LOCKED QUICK ACTIONS:
  // Cases, Calendar, Reminders, Fees, Starred, Team.
  static const actions = [
    _QuickAction(
      'Cases',
      Icons.gavel_rounded,
      '/cases',
    ),
    _QuickAction(
      'Calendar',
      Icons.calendar_month_rounded,
      '/calendar',
    ),
    _QuickAction(
      'Reminders',
      Icons.notifications_none_rounded,
      '/reminders',
    ),
    _QuickAction(
      'Fees',
      Icons.calculate_outlined,
      '/fee',
    ),
    _QuickAction(
      'Starred',
      Icons.star_outline_rounded,
      '/starred',
    ),
    _QuickAction(
      'Team',
      Icons.groups_outlined,
      '/team',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(
          eyebrow: 'SHORTCUTS',
          title: 'Quick actions',
        ),
        const SizedBox(height: 13),
        SizedBox(
          height: 91,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: actions.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final action = actions[index];

              return _QuickActionTile(
                action: action,
                onTap: () =>
                    onRoute(action.route),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickAction {
  const _QuickAction(
    this.label,
    this.icon,
    this.route,
  );

  final String label;
  final IconData icon;
  final String route;
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.action,
    required this.onTap,
  });

  final _QuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      child: Material(
        color: _HomeColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 7,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _HomeColors.border,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _HomeColors.primaryGreen
                        .withValues(alpha: .08),
                    borderRadius:
                        BorderRadius.circular(11),
                  ),
                  child: Icon(
                    action.icon,
                    color: _HomeColors.primaryGreen,
                    size: 19,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  action.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _HomeColors.textSecondary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
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

// =============================================================================
// TODAY'S SCHEDULE
// =============================================================================

class _TodaySchedule extends StatelessWidget {
  const _TodaySchedule({
    required this.userId,
    required this.onViewCalendar,
  });

  final String? userId;
  final VoidCallback onViewCalendar;

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return _ScheduleCard(
        entries: const [],
        onViewCalendar: onViewCalendar,
      );
    }

    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('cases')
          .where(
            'userId',
            isEqualTo: userId,
          )
          .snapshots(),
      builder: (context, snapshot) {
        final entries = snapshot.hasData
            ? _todayEntries(snapshot.data!.docs)
            : const <_ScheduleEntry>[];

        return _ScheduleCard(
          entries: entries,
          onViewCalendar: onViewCalendar,
        );
      },
    );
  }

  List<_ScheduleEntry> _todayEntries(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
        documents,
  ) {
    final today =
        DateUtils.dateOnly(DateTime.now());

    final results = <_ScheduleEntry>[];

    for (final document in documents) {
      final data = document.data();
      final value = data['nextHearingDate'];

      if (value is! Timestamp) continue;

      final date = value.toDate();

      if (!DateUtils.isSameDay(today, date)) {
        continue;
      }

      final title =
          (data['caseTitle'] as String?)?.trim();

      if (title == null || title.isEmpty) {
        continue;
      }

      final court =
          (data['courtName'] as String?)?.trim();

      results.add(
        _ScheduleEntry(
          title: title,
          time: TimeOfDay.fromDateTime(date),
          location: court,
        ),
      );
    }

    results.sort(
      (a, b) {
        final aMinutes =
            a.time.hour * 60 + a.time.minute;

        final bMinutes =
            b.time.hour * 60 + b.time.minute;

        return aMinutes.compareTo(bMinutes);
      },
    );

    return results
        .take(3)
        .toList(growable: false);
  }
}

class _ScheduleEntry {
  const _ScheduleEntry({
    required this.title,
    required this.time,
    this.location,
  });

  final String title;
  final TimeOfDay time;
  final String? location;
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.entries,
    required this.onViewCalendar,
  });

  final List<_ScheduleEntry> entries;
  final VoidCallback onViewCalendar;

  @override
  Widget build(BuildContext context) {
    return _HomeCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _SectionHeading(
                  eyebrow: 'TODAY',
                  title: 'Schedule',
                ),
              ),
              TextButton(
                onPressed: onViewCalendar,
                style: TextButton.styleFrom(
                  foregroundColor:
                      _HomeColors.primaryGreen,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Calendar',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (entries.isEmpty)
            const _EmptySchedule()
          else
            ...List.generate(
              entries.length,
              (index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom:
                        index == entries.length - 1
                            ? 0
                            : 10,
                  ),
                  child: _ScheduleRow(
                    entry: entries[index],
                    isLast:
                        index ==
                            entries.length - 1,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.entry,
    required this.isLast,
  });

  final _ScheduleEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final localizations =
        MaterialLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _HomeColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _HomeColors.border,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            child: Text(
              localizations.formatTimeOfDay(
                entry.time,
              ),
              style: const TextStyle(
                color: _HomeColors.primaryGreen,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 34,
            color: _HomeColors.border,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _HomeColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (entry.location != null &&
                    entry.location!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    entry.location!,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _HomeColors.textMuted,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: _HomeColors.textMuted,
            size: 19,
          ),
        ],
      ),
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  const _EmptySchedule();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        color: _HomeColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _HomeColors.border,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.event_available_rounded,
            color: _HomeColors.primaryGreen,
            size: 25,
          ),
          SizedBox(height: 9),
          Text(
            'Your schedule is clear',
            style: TextStyle(
              color: _HomeColors.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'No hearings or meetings scheduled today.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _HomeColors.textMuted,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// WORKSPACE
// =============================================================================

class _WorkspaceSection extends StatelessWidget {
  const _WorkspaceSection({
    required this.title,
    required this.onEdit,
    required this.child,
  });

  final String title;
  final VoidCallback onEdit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _SectionHeading(
                eyebrow: 'WORKSPACE',
                title: title,
              ),
            ),
            IconButton(
              onPressed: onEdit,
              tooltip: 'Rename workspace',
              icon: const Icon(
                Icons.edit_outlined,
                color: _HomeColors.textMuted,
                size: 18,
              ),
              visualDensity:
                  VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 13),
        child,
      ],
    );
  }
}

class _WorkspaceCard extends StatelessWidget {
  const _WorkspaceCard({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _HomeCard(
      padding: const EdgeInsets.all(18),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _HomeColors.primaryGreen
                        .withValues(alpha: .08),
                    borderRadius:
                        BorderRadius.circular(15),
                    border: Border.all(
                      color: _HomeColors.primaryGreen
                          .withValues(alpha: .16),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color:
                        _HomeColors.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        eyebrow,
                        style: const TextStyle(
                          color:
                              _HomeColors.accentGold,
                          fontSize: 9,
                          fontWeight:
                              FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color:
                              _HomeColors.textPrimary,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w700,
                          fontFamily: 'serif',
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color:
                              _HomeColors.textMuted,
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color:
                          _HomeColors.primaryGreen,
                      size: 19,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      actionLabel,
                      style: const TextStyle(
                        color:
                            _HomeColors.textMuted,
                        fontSize: 9,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// REMINDERS
// =============================================================================

class _RemindersSection extends StatelessWidget {
  const _RemindersSection({
    required this.onViewAll,
  });

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return _HomeCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _HomeColors.primaryGreen
                      .withValues(alpha: .08),
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color:
                      _HomeColors.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reminders',
                      style: TextStyle(
                        color:
                            _HomeColors.textPrimary,
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w700,
                        fontFamily: 'serif',
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Keep track of important follow-ups.',
                      style: TextStyle(
                        color:
                            _HomeColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  foregroundColor:
                      _HomeColors.primaryGreen,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize:
                      MaterialTapTargetSize
                          .shrinkWrap,
                ),
                child: const Text(
                  'View all',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: _HomeColors.surfaceSoft,
              borderRadius:
                  BorderRadius.circular(13),
              border: Border.all(
                color: _HomeColors.border,
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color:
                      _HomeColors.textMuted,
                  size: 18,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No reminders right now.',
                    style: TextStyle(
                      color:
                          _HomeColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// COMMON COMPONENTS
// =============================================================================

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
  });

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: _HomeColors.accentGold,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: _HomeColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w700,
            fontFamily: 'serif',
            letterSpacing: -.2,
          ),
        ),
      ],
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _HomeColors.surface,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: _HomeColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

// =============================================================================
// TEMPLATE PICKER
// =============================================================================

class _TemplatePicker extends StatelessWidget {
  const _TemplatePicker({
    required this.onSelected,
  });

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        22,
        12,
        22,
        28,
      ),
      decoration: const BoxDecoration(
        color: _HomeColors.surface,
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color:
                      _HomeColors.borderStrong,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Choose a workspace',
              style: TextStyle(
                color:
                    _HomeColors.textPrimary,
                fontSize: 23,
                fontWeight:
                    FontWeight.w700,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Select the workflow you want to prioritize.',
              style: TextStyle(
                color:
                    _HomeColors.textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            ...const [
              'Daily Cases',
              'Legal Research',
              'Custom',
            ].map(
              (option) => _TemplateOption(
                label: option,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateOption extends StatelessWidget {
  const _TemplateOption({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(
        vertical: 2,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _HomeColors.primaryGreen
              .withValues(alpha: .08),
          borderRadius:
              BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.dashboard_outlined,
          color: _HomeColors.primaryGreen,
          size: 19,
        ),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: _HomeColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: _HomeColors.textMuted,
      ),
      onTap: () {
        final sheet =
            context.findAncestorWidgetOfExactType<
                _TemplatePicker>();

        if (sheet != null) {
          sheet.onSelected(label);
        }
      },
    );
  }
}

// =============================================================================
// DRAWER
// =============================================================================

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer({
    required this.userName,
    required this.onNavigate,
  });

  final String userName;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppPalette.canvas,
      child: SafeArea(
        child: StreamBuilder<SubscriptionInfo>(
          stream: SubscriptionService.instance
              .watchSubscription(),
          builder: (context, snapshot) {
            final sub = snapshot.data ??
                SubscriptionInfo.defaultFree;

            return ListView(
              padding:
                  const EdgeInsets.fromLTRB(
                14,
                14,
                14,
                24,
              ),
              children: [
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    10,
                    8,
                    10,
                    18,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration:
                            BoxDecoration(
                          color:
                              AppPalette.primaryGreen,
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color:
                                  Color(0x181F3D2B),
                              blurRadius: 8,
                              offset:
                                  Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.gavel_rounded,
                            color:
                                AppPalette.accentGold,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              userName,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style: const TextStyle(
                                color:
                                    AppPalette
                                        .textPrimary,
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w700,
                                fontFamily:
                                    'serif',
                              ),
                            ),
                            const SizedBox(
                                height: 3),
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: sub.isCloud
                                    ? AppPalette
                                        .primaryGreen
                                        .withValues(
                                      alpha: 0.12,
                                    )
                                    : AppPalette
                                        .textMuted
                                        .withValues(
                                      alpha: 0.12,
                                    ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  5,
                                ),
                              ),
                              child: Text(
                                sub.isCloud
                                    ? 'Cloud Subscriber'
                                    : 'Free Workspace',
                                style: TextStyle(
                                  color: sub.isCloud
                                      ? AppPalette
                                          .primaryGreen
                                      : AppPalette
                                          .textMuted,
                                  fontSize: 10,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                  letterSpacing:
                                      0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: AppPalette.borderLight,
                  height: 1,
                ),
                const SizedBox(height: 12),

                _sectionHeader('WORKSPACE'),

                _drawerItem(
                  context,
                  'Cases',
                  Icons.business_center_outlined,
                  '/cases',
                ),

                _drawerItem(
                  context,
                  'Clients',
                  Icons.groups_outlined,
                  '/clients',
                ),

                const SizedBox(height: 12),
                const Divider(
                  color: AppPalette.borderLight,
                  height: 1,
                ),
                const SizedBox(height: 12),

                _sectionHeader(
                    'CLOUD & ACCOUNT'),

                if (sub.isCloud)
                  _drawerItem(
                    context,
                    'Cloud & Sync',
                    Icons.cloud_sync_outlined,
                    '/cloud_storage',
                  ),

                if (sub.isFree)
                  _drawerItem(
                    context,
                    'Upgrade',
                    Icons.workspace_premium_outlined,
                    '/upgrade',
                    isHighlight: true,
                  ),

                _drawerItem(
                  context,
                  'Settings',
                  Icons.settings_outlined,
                  '/settings',
                ),

                const SizedBox(height: 12),
                const Divider(
                  color: AppPalette.borderLight,
                  height: 1,
                ),
                const SizedBox(height: 12),

                _sectionHeader('SUPPORT'),

                _drawerItem(
                  context,
                  'Help & Support',
                  Icons.help_outline_rounded,
                  '/support',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        14,
        4,
        14,
        8,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: AppPalette.textMuted,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    String label,
    IconData icon,
    String route, {
    bool isHighlight = false,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),
      leading: Icon(
        icon,
        color: isHighlight
            ? AppPalette.accentGold
            : AppPalette.primaryGreen,
        size: 21,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isHighlight
              ? const Color(0xFF8A6200)
              : AppPalette.textPrimary,
          fontSize: 13.5,
          fontWeight: isHighlight
              ? FontWeight.w700
              : FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppPalette.textMuted,
        size: 18,
      ),
      onTap: () {
        Navigator.pop(context);
        onNavigate(route);
      },
    );
  }
}

// =============================================================================
// HOME COLORS — MODERN LEGAL EDITORIAL
// =============================================================================

abstract final class _HomeColors {
  // Canvas
  static const background =
      Color(0xFFF7F5F2);

  // White paper/card surface
  static const surface =
      Color(0xFFFFFFFF);

  // Warm secondary surface
  static const surfaceSoft =
      Color(0xFFF3F0EB);

  // Warm editorial borders
  static const border =
      Color(0xFFE5DFD7);

  static const borderStrong =
      Color(0xFFD8D0C6);

  // Primary legal authority
  static const primaryGreen =
      Color(0xFF1F3D2B);
      
  // Restrained prestige
  static const accentGold =
      Color(0xFFCCA046);

  // Typography
  static const textPrimary =
      Color(0xFF1A1A1A);

  static const textSecondary =
      Color(0xFF4F4B45);

  static const textMuted =
      Color(0xFF6B665E);
}