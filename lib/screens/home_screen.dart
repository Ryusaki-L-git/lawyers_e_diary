import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ld_logo.dart';
import '../widgets/home_bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.simulateNewNotification = true});

  /// Retained for compatibility with the existing notification flow.
  final bool simulateNewNotification;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _templateTitleKey = 'home_template_title';
  static const _templateSelectionKey = 'home_template_selection';
  static const _templateSelectedKey = 'home_template_was_selected';

  late final PageController _featureController;
  bool _hasUnreadNotifications = false;
  String _templateTitle = 'My Templates';
  String? _templateSelection;

  @override
  void initState() {
    super.initState();
    _hasUnreadNotifications = widget.simulateNewNotification;
    _featureController = PageController(viewportFraction: .50);
    _restoreTemplatePreference();
  }

  Future<void> _restoreTemplatePreference() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _templateTitle = preferences.getString(_templateTitleKey) ?? 'My Templates';
      _templateSelection = preferences.getString(_templateSelectionKey);
    });
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.simulateNewNotification && !oldWidget.simulateNewNotification) {
      setState(() => _hasUnreadNotifications = true);
    }
  }

  @override
  void dispose() {
    _featureController.dispose();
    super.dispose();
  }

  void _openRoute(String route) => Navigator.of(context).pushNamed(route);

  Future<void> _openNotifications() async {
    await Navigator.of(context).pushNamed('/notifications');
    if (mounted && _hasUnreadNotifications) {
      setState(() => _hasUnreadNotifications = false);
    }
  }

  Future<void> _editTemplateTitle() async {
    final controller = TextEditingController(text: _templateTitle);
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _HomeColors.paper,
        title: const Text('Edit template title'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 32,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'My Templates'),
          onSubmitted: (value) => Navigator.pop(dialogContext, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();

    final value = title?.trim();
    if (value == null || value.isEmpty || !mounted) return;
    setState(() => _templateTitle = value);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_templateTitleKey, value);
  }

  Future<void> _handleTemplateTap() async {
    final preferences = await SharedPreferences.getInstance();
    final hasSelectedBefore = preferences.getBool(_templateSelectedKey) ?? false;
    if (!hasSelectedBefore) {
      if (!mounted) return;
      final selection = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => _TemplatePicker(
          onSelected: (value) => Navigator.pop(sheetContext, value),
        ),
      );
      if (selection == null || !mounted) return;

      setState(() {
        _templateSelection = selection;
        _templateTitle = selection;
      });
      await preferences.setBool(_templateSelectedKey, true);
      await preferences.setString(_templateSelectionKey, selection);
      await preferences.setString(_templateTitleKey, selection);
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = _displayName(user);

    return Scaffold(
      backgroundColor: _HomeColors.cream,
      appBar: AppBar(
        backgroundColor: _HomeColors.cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        iconTheme: const IconThemeData(color: _HomeColors.brown, size: 28),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                tooltip: 'Notifications',
                onPressed: _openNotifications,
                icon: const Icon(Icons.notifications_none_rounded, size: 27),
              ),
              if (_hasUnreadNotifications)
                const Positioned(
                  top: 14,
                  right: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _HomeColors.gold,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(width: 10, height: 10),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _HomeDrawer(userName: userName, onNavigate: _openRoute),
      bottomNavigationBar: HomeBottomNavigation(
        currentIndex: 0,
        onNavigate: _openRoute,
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _WelcomeHeader(userName: userName),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 170,
                    child: PageView.builder(
                      controller: _featureController,
                      itemCount: _features.length,
                      padEnds: false,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.only(
                          right: index == _features.length - 1 ? 0 : 12,
                        ),
                        child: _FeatureCard(
                          feature: _features[index],
                          onTap: () => _openRoute(_features[index].route),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _SectionTitle(title: _templateTitle, onEdit: _editTemplateTitle),
                  const SizedBox(height: 12),
                  _buildSelectedTemplateCard(),
                  const SizedBox(height: 24),
                  _TodaySchedule(
                    userId: user?.uid,
                    onViewCalendar: () => _openRoute('/calendar'),
                  ),
                  const SizedBox(height: 20),
                  _RemindersEmptyState(onViewAll: () => _openRoute('/reminders')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTemplateCard() {
    switch (_templateSelection) {
      case 'Daily Cases':
        return buildDailyCasesCard();
      case 'Legal Research':
        return buildLegalResearchCard();
      case 'Custom':
        return buildCustomCard();
      default:
        return _TemplateCard(
          icon: Icons.add_rounded,
          title: 'Add any other\nuseful features',
          subtitle: 'Customize your workspace',
          onTap: _handleTemplateTap,
        );
    }
  }

  Widget buildDailyCasesCard() => _TemplateCard(
        icon: Icons.calendar_today_rounded,
        title: 'Daily cases',
        subtitle: 'Review your case diary',
        onTap: () => Navigator.pushNamed(context, '/cases'),
      );

  Widget buildLegalResearchCard() => _TemplateCard(
        icon: Icons.auto_stories_rounded,
        title: 'Legal research',
        subtitle: 'Open Drafting Studio',
        onTap: () => Navigator.pushNamed(context, '/juris'),
      );

  Widget buildCustomCard() => _TemplateCard(
        icon: Icons.dashboard_customize_outlined,
        title: 'Custom workspace',
        subtitle: 'Manage your workspace',
        onTap: () => Navigator.pushNamed(context, '/profile'),
      );

  String _displayName(User? user) {
    final displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    final emailPrefix = user?.email?.split('@').first.trim();
    if (emailPrefix != null && emailPrefix.isNotEmpty) {
      return emailPrefix[0].toUpperCase() + emailPrefix.substring(1);
    }
    return 'Counsel';
  }
}

const _features = <_FeatureDefinition>[
  _FeatureDefinition('To Do List', Icons.checklist_rounded, '/todo',
      Color(0xFF1D6A30), Color(0xFF58A84D)),
  _FeatureDefinition(
      'Team', Icons.groups_rounded, '/clients', Color(0xFFA94D00), Color(0xFFF19B0A)),
  _FeatureDefinition('Fee\nCalculator', Icons.calculate_rounded, '/fee',
      Color(0xFF00604E), Color(0xFF008F77)),
  _FeatureDefinition('Services', Icons.folder_rounded, '/juris',
      Color(0xFFB36E00), Color(0xFFFFB000)),
  _FeatureDefinition('Starred\nCases', Icons.star_border_rounded, '/starred',
      Color(0xFF8F0808), Color(0xFFC9231E)),
];

class _FeatureDefinition {
  const _FeatureDefinition(
      this.label, this.icon, this.route, this.dark, this.light);

  final String label;
  final IconData icon;
  final String route;
  final Color dark;
  final Color light;
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.userName});
  final String userName;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Good morning',
                  style: TextStyle(
                    color: _HomeColors.muted,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Adv. $userName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _HomeColors.brown,
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Have a productive day ahead!',
                  style: TextStyle(
                    color: _HomeColors.muted,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const SizedBox(width: 96, child: LawFirmMark()),
        ],
      );
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature, required this.onTap});
  final _FeatureDefinition feature;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Center(
        child: Material(
          color: _HomeColors.paper,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 16, 10, 13),
              decoration: _cardDecoration(radius: 20),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [feature.light, feature.dark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x330F0803),
                          blurRadius: 8,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      feature.icon,
                      color: Colors.white.withValues(alpha: .82),
                      size: 34,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    feature.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.onEdit});
  final String title;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _HomeColors.brown,
                fontFamily: 'serif',
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: onEdit,
            tooltip: 'Edit title',
            icon: const Icon(
              Icons.edit_outlined,
              color: _HomeColors.gold,
              size: 21,
            ),
          ),
        ],
      );
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: _HomeColors.paper,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 172),
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
            decoration: _cardDecoration(radius: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: _HomeColors.paleGold,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 30, color: _HomeColors.gold),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subtitle,
                        style: const TextStyle(
                          color: _HomeColors.muted,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const _ArrowButton(),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}

class _TodaySchedule extends StatelessWidget {
  const _TodaySchedule({required this.userId, required this.onViewCalendar});
  final String? userId;
  final VoidCallback onViewCalendar;

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return _ScheduleShell(onViewCalendar: onViewCalendar, entries: const []);
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('cases')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        final entries = snapshot.hasData
            ? _todayEntries(snapshot.data!.docs)
            : const <_ScheduleEntry>[];
        return _ScheduleShell(onViewCalendar: onViewCalendar, entries: entries);
      },
    );
  }

  List<_ScheduleEntry> _todayEntries(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) {
    final today = DateUtils.dateOnly(DateTime.now());
    final results = <_ScheduleEntry>[];
    for (final document in documents) {
      final data = document.data();
      final value = data['nextHearingDate'];
      if (value is! Timestamp) continue;
      final date = value.toDate();
      if (!DateUtils.isSameDay(today, date)) continue;
      final title = (data['caseTitle'] as String?)?.trim();
      if (title == null || title.isEmpty) continue;
      final court = (data['courtName'] as String?)?.trim();
      results.add(
        _ScheduleEntry(
          title: title,
          time: TimeOfDay.fromDateTime(date),
          location: court,
        ),
      );
    }
    results.sort(
      (a, b) =>
          a.time.hour * 60 + a.time.minute - (b.time.hour * 60 + b.time.minute),
    );
    return results.take(3).toList(growable: false);
  }
}

class _ScheduleShell extends StatelessWidget {
  const _ScheduleShell({required this.onViewCalendar, required this.entries});
  final VoidCallback onViewCalendar;
  final List<_ScheduleEntry> entries;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: _cardDecoration(radius: 20),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: _HomeColors.gold,
                  size: 25,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "Today's Schedule",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _HomeColors.brown,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onViewCalendar,
                  style: TextButton.styleFrom(
                    foregroundColor: _HomeColors.gold,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('View Calendar', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  'No hearings or meetings scheduled for today.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _HomeColors.muted, fontSize: 15),
                ),
              )
            else
              ...entries.map((entry) => _ScheduleRow(entry: entry)),
          ],
        ),
      );
}

class _ScheduleEntry {
  const _ScheduleEntry({required this.title, required this.time, this.location});
  final String title;
  final TimeOfDay time;
  final String? location;
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.entry});
  final _ScheduleEntry entry;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _HomeColors.paleGreen,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            child: Text(
              localizations.formatTimeOfDay(entry.time),
              style: const TextStyle(
                color: Color(0xFF1D7337),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const VerticalDivider(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                if (entry.location != null && entry.location!.isNotEmpty)
                  Text(
                    entry.location!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _HomeColors.muted),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RemindersEmptyState extends StatelessWidget {
  const _RemindersEmptyState({required this.onViewAll});
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        decoration: _cardDecoration(radius: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: _HomeColors.brown,
                  size: 25,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Reminders',
                    style: TextStyle(
                      color: _HomeColors.brown,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    foregroundColor: _HomeColors.gold,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('View All', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'No reminders right now.',
              style: TextStyle(color: _HomeColors.muted, fontSize: 15),
            ),
          ],
        ),
      );
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton();

  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 38,
        decoration: BoxDecoration(
          color: _HomeColors.paleGold,
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Icon(
          Icons.arrow_forward_rounded,
          color: _HomeColors.gold,
        ),
      );
}

class _TemplatePicker extends StatelessWidget {
  const _TemplatePicker({required this.onSelected});
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: const BoxDecoration(
          color: _HomeColors.paper,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4DCCD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Choose a template',
                style: TextStyle(
                  color: _HomeColors.brown,
                  fontFamily: 'serif',
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              for (final option in const [
                'Daily Cases',
                'Legal Research',
                'Custom',
              ])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: _HomeColors.gold,
                  ),
                  onTap: () => onSelected(option),
                ),
            ],
          ),
        ),
      );
}

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer({required this.userName, required this.onNavigate});
  final String userName;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) => Drawer(
        backgroundColor: _HomeColors.paper,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 15, 22, 20),
                child: Text(
                  userName,
                  style: const TextStyle(
                    color: _HomeColors.brown,
                    fontFamily: 'serif',
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _drawerItem(context, 'Cases', Icons.gavel_rounded, '/cases'),
              _drawerItem(context, 'Clients', Icons.groups_rounded, '/clients'),
              _drawerItem(
                context,
                'Calendar',
                Icons.calendar_month_rounded,
                '/calendar',
              ),
              _drawerItem(
                context,
                'Drafting Studio',
                Icons.auto_awesome_rounded,
                '/juris',
              ),
              _drawerItem(
                context,
                'Settings',
                Icons.settings_outlined,
                '/profile',
              ),
            ],
          ),
        ),
      );

  Widget _drawerItem(
    BuildContext context,
    String label,
    IconData icon,
    String route,
  ) =>
      ListTile(
        leading: Icon(icon, color: _HomeColors.brown),
        title: Text(
          label,
          style: const TextStyle(
            color: _HomeColors.brown,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          onNavigate(route);
        },
      );
}



BoxDecoration _cardDecoration({required double radius}) => BoxDecoration(
      color: _HomeColors.paper,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: const Color(0xFFF0E9DE)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A3E2814),
          blurRadius: 14,
          offset: Offset(0, 6),
        ),
      ],
    );

abstract final class _HomeColors {
  static const cream = Color(0xFFFFF9ED);
  static const paper = Color(0xFFFFFEFC);
  static const brown = Color(0xFF342319);
  static const muted = Color(0xFF76716C);
  static const gold = Color(0xFFC68200);
  static const paleGold = Color(0xFFFFF6DF);
  static const paleGreen = Color(0xFFF1F8ED);
}
