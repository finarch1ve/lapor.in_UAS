import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketing_uts/main.dart';
import 'package:ticketing_uts/providers/auth_provider.dart';
import 'package:ticketing_uts/providers/ticket_provider.dart';
import 'package:ticketing_uts/providers/notification_provider.dart';
import 'package:ticketing_uts/widgets/app_button.dart';
import 'package:ticketing_uts/widgets/app_card.dart';
import 'package:ticketing_uts/widgets/unair_logo.dart';
import 'ticket_list_screen.dart';
import 'create_ticket_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';
import 'user_management_screen.dart';
import 'admin_ticket_screen.dart';
import 'ticket_detail_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const DashboardScreen({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificationProvider.notifier).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final ticketState = ref.watch(ticketProvider);
    final unreadCount = ref.watch(unreadCountProvider);
    final theme = Theme.of(context);
    final currentThemeMode = ref.watch(themeModeProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = [
      _buildHome(ticketState, user, theme),
      TicketListScreen(onToggleTheme: widget.onToggleTheme, themeMode: currentThemeMode),
      CreateTicketScreen(onToggleTheme: widget.onToggleTheme, themeMode: currentThemeMode),
      NotificationScreen(),
      ProfileScreen(onToggleTheme: widget.onToggleTheme, themeMode: currentThemeMode),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const UnairHeaderLogo(logoSize: 32),
        actions: [
          // Notification bell
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  setState(() => _selectedIndex = 3);
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Theme toggle
          IconButton(
            icon: Icon(theme.brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              final notifier = ref.read(themeModeProvider.notifier);
              notifier.state = notifier.state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
            },
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.bottomNavigationBarTheme.backgroundColor,
          border: Border(
            top: BorderSide(color: theme.dividerColor, width: 1),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 65,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  index: 0,
                  selectedIcon: Icons.dashboard,
                  theme: theme,
                ),
                _buildNavItem(
                  icon: Icons.list_alt_outlined,
                  label: 'Tiket',
                  index: 1,
                  selectedIcon: Icons.list_alt,
                  theme: theme,
                ),
                // FAB - Create button (elevated)
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 2),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [theme.primaryColor, const Color(0xFF0047a8)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                _buildNavItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notif',
                  index: 3,
                  selectedIcon: Icons.notifications,
                  theme: theme,
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  label: 'Profil',
                  index: 4,
                  selectedIcon: Icons.person,
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required ThemeData theme,
    IconData? selectedIcon,
  }) {
    final isSelected = _selectedIndex == index;
    final activeColor = theme.bottomNavigationBarTheme.selectedItemColor ?? theme.primaryColor;
    final inactiveColor = theme.bottomNavigationBarTheme.unselectedItemColor ?? theme.textTheme.bodySmall?.color;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? (selectedIcon ?? icon) : icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHome(dynamic ticketState, dynamic user, ThemeData theme) {
    final stats = ref.read(ticketProvider.notifier).getStatistics();
    final tickets = user?.isAdmin == true
        ? ticketState.tickets
        : user?.isHelpdesk == true
            ? ticketState.assignedTickets
            : ticketState.myTickets;

    final activeCount = (stats['Menunggu'] ?? 0) + (stats['Diproses'] ?? 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero card
          HeroCard(
            userName: user?.name ?? 'User',
            role: user?.role ?? 'user',
            activeTicketCount: activeCount,
          ),

          // Stats row
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Menunggu',
                  value: stats['Menunggu'] ?? 0,
                  color: const Color(0xFFf57c00),
                  icon: Icons.hourglass_empty,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'Diproses',
                  value: stats['Diproses'] ?? 0,
                  color: const Color(0xFF7b1fa2),
                  icon: Icons.sync,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'Selesai',
                  value: stats['Selesai'] ?? 0,
                  color: const Color(0xFF2e7d32),
                  icon: Icons.check_circle,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent tickets section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiket Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              if (tickets.length > 5)
                TextButton(
                  onPressed: () => setState(() => _selectedIndex = 1),
                  child: const Text('Lihat Semua'),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (tickets.isEmpty)
            const EmptyStateCard(
              message: 'Belum ada tiket',
              icon: Icons.inbox,
            )
          else
            ...tickets.take(5).map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TicketCard(
                    title: t.title ?? 'Tanpa judul',
                    ticketId: t.displayId ?? t.id ?? '#???',
                    category: t.category ?? 'Lainnya',
                    date: t.formattedDate ?? '',
                    status: t.status ?? 'Menunggu',
                    onTap: () async {
                      final currentThemeMode = ref.read(themeModeProvider);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TicketDetailScreen(
                            ticketId: t.id,
                            onToggleTheme: widget.onToggleTheme,
                            themeMode: currentThemeMode,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                )),

          const SizedBox(height: 16),

          // Admin-specific buttons
          if (user?.isAdmin == true) ...[
            // Quick actions grid
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.add_circle_outline,
                    label: 'Buat Tiket',
                    color: theme.primaryColor,
                    bgColor: theme.primaryColor.withValues(alpha: 0.1),
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.people_outline,
                    label: 'Kelola User',
                    color: const Color(0xFFc45000),
                    bgColor: const Color(0xFFc45000).withValues(alpha: 0.12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const UserManagementScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Semua Tiket',
                    color: const Color(0xFF4527a0),
                    bgColor: const Color(0xFF4527a0).withValues(alpha: 0.12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminTicketScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.history_outlined,
                    label: 'Riwayat',
                    color: const Color(0xFF1b5e20),
                    bgColor: const Color(0xFF1b5e20).withValues(alpha: 0.12),
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Full width buttons
            AppButtonFull(
              label: 'Manajemen Tiket',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminTicketScreen()),
                );
              },
              icon: Icons.admin_panel_settings,
              isSecondary: true,
            ),
            const SizedBox(height: 8),
            AppButtonFull(
              label: 'Kelola Pengguna',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserManagementScreen()),
                );
              },
              icon: Icons.people,
              isDanger: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}