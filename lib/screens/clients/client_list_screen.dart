import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/client_model.dart';
import '../../services/client_service.dart';
import '../../widgets/app_palette.dart';
import 'add_edit_client_screen.dart';
import 'client_detail_screen.dart';

/// Production Client Management Directory Screen.
/// Includes real-time 300ms debounced multi-field search, client type filters,
/// soft-deleted exclusion, and "+ Add Client" action.
class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  String _searchQuery = '';
  String _activeTypeFilter = 'All';

  static const List<String> _filters = [
    'All',
    'Individual',
    'Corporate',
    'Government',
  ];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() => _searchQuery = query.trim());
    });
  }

  void _openAddClient() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditClientScreen()),
    );
  }

  void _openClientDetail(ClientModel client) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClientDetailScreen(client: client),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.canvas,
      appBar: AppBar(
        backgroundColor: AppPalette.canvas,
        foregroundColor: AppPalette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: true,
        title: const Text(
          'Client Directory',
          style: TextStyle(
            color: AppPalette.textPrimary,
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddClient,
        backgroundColor: AppPalette.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_outlined, size: 20),
        label: const Text(
          'Add Client',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Field
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: AppPalette.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppPalette.borderLight),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.search_rounded,
                        color: AppPalette.textMuted,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: const TextStyle(
                          color: AppPalette.textPrimary,
                          fontSize: 13.5,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search by client name, phone, email...',
                          hintStyle: TextStyle(
                            color: AppPalette.textMuted,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppPalette.textMuted,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                  ],
                ),
              ),
            ),

            // Type Filter Chips Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Row(
                children: _filters.map((filter) {
                  final isSel = _activeTypeFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSel,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _activeTypeFilter = filter);
                        }
                      },
                      selectedColor: AppPalette.primaryGreen,
                      backgroundColor: AppPalette.cardBackground,
                      side: BorderSide(
                        color: isSel
                            ? AppPalette.primaryGreen
                            : AppPalette.borderLight,
                      ),
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppPalette.textPrimary,
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 6),

            // Directory Stream List
            Expanded(
              child: StreamBuilder<List<ClientModel>>(
                stream: ClientService.instance.watchClients(
                  searchQuery: _searchQuery,
                  typeFilter: _activeTypeFilter,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppPalette.primaryGreen,
                        strokeWidth: 2.5,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading clients: ${snapshot.error}',
                        style: const TextStyle(color: AppPalette.textMuted),
                      ),
                    );
                  }

                  final clients = snapshot.data ?? [];

                  if (clients.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 80),
                    physics: const BouncingScrollPhysics(),
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index];
                      return _ClientCard(
                        client: client,
                        onTap: () => _openClientDetail(client),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasFilter = _searchQuery.isNotEmpty || _activeTypeFilter != 'All';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppPalette.primaryGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilter ? Icons.search_off_rounded : Icons.groups_outlined,
                color: AppPalette.primaryGreen,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilter ? 'No Matching Clients' : 'No Clients Registered Yet',
              style: const TextStyle(
                color: AppPalette.textPrimary,
                fontFamily: 'serif',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'No clients matched your current search or filter criteria.'
                  : 'Establish client records to retain contact particulars, notes, and institutional profiles.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppPalette.textMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            if (hasFilter) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _activeTypeFilter = 'All';
                  });
                },
                child: const Text(
                  'Reset Filters',
                  style: TextStyle(
                    color: AppPalette.primaryGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({required this.client, required this.onTap});

  final ClientModel client;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initials = client.name.trim().isNotEmpty
        ? client.name.trim().split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join().toUpperCase()
        : 'CL';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppPalette.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Initials Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppPalette.primaryGreen,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: AppPalette.accentGold,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Client Particulars
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              client.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppPalette.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppPalette.primaryGreen.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              client.type.toUpperCase(),
                              style: const TextStyle(
                                color: AppPalette.primaryGreen,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 13,
                            color: AppPalette.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            client.phone.isNotEmpty
                                ? client.phone
                                : 'No phone recorded',
                            style: const TextStyle(
                              color: AppPalette.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppPalette.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

