import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketing_uts/providers/auth_provider.dart';
import 'package:ticketing_uts/config/supabase_config.dart';
import 'package:ticketing_uts/models/user_model.dart';
import 'package:ticketing_uts/widgets/app_colors.dart';
import 'package:ticketing_uts/widgets/app_card.dart';
import 'package:ticketing_uts/widgets/status_badge.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final Map<String, bool> _loadingStates = {};
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await SupabaseConfig.client
          .from('users')
          .select()
          .order('created_at', ascending: false);

      final users = (response as List)
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat users: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _changeRole(UserModel user, String newRole) async {
    setState(() => _loadingStates[user.id] = true);

    try {
      await SupabaseConfig.client
          .from('users')
          .update({'role': newRole})
          .eq('id', user.id);

      await _fetchUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Role ${user.name} diubah ke $newRole'),
            backgroundColor: const Color(0xFF2e7d32),
          ),
        );
      }
    } catch (e) {
      setState(() => _loadingStates[user.id] = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update role: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _toggleActiveStatus(UserModel user) async {
    final newStatus = !(user.isActive ?? true);
    setState(() => _loadingStates[user.id] = true);

    try {
      await SupabaseConfig.client
          .from('users')
          .update({'is_active': newStatus})
          .eq('id', user.id);

      await _fetchUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(user.name! + (newStatus ? ' diaktifkan' : ' dinonaktifkan')),
            backgroundColor: const Color(0xFF2e7d32),
          ),
        );
      }
    } catch (e) {
      setState(() => _loadingStates[user.id] = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update status: ${e.toString()}')),
        );
      }
    }
  }

  void _showRoleDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ubah Role - ${user.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['user', 'helpdesk', 'admin'].map((role) {
            return RadioListTile<String>(
              title: Text(role.toUpperCase()),
              value: role,
              groupValue: user.role,
              onChanged: (value) {
                if (value != null) {
                  Navigator.pop(context);
                  _changeRole(user, value);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kelola Pengguna'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUsers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const EmptyStateCard(
                  message: 'Belum ada pengguna',
                  icon: Icons.people_outline,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _users.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    final isLoading = _loadingStates[user.id] ?? false;
                    final isCurrentUser = currentUser?.id == user.id;

                    return AppCard(
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.getRoleBg(user.role),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Center(
                            child: Text(
                              user.name.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                color: AppColors.getRoleColor(user.role),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            RoleBadge(role: user.role, fontSize: 10),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(user.email),
                            if (user.studentId != null || user.className != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                '${user.studentId ?? ''} ${user.className != null ? '• ${user.className}' : ''}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                        trailing: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : PopupMenuButton<String>(
                                enabled: !isCurrentUser,
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) {
                                  if (value == 'role') {
                                    _showRoleDialog(user);
                                  } else if (value == 'status') {
                                    _toggleActiveStatus(user);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'role',
                                    child: Row(
                                      children: [
                                        Icon(Icons.swap_horiz, size: 18),
                                        SizedBox(width: 8),
                                        Text('Ubah Role'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'status',
                                    child: Row(
                                      children: [
                                        Icon(
                                          user.isActive ?? true
                                              ? Icons.block
                                              : Icons.check_circle,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(user.isActive ?? true
                                            ? 'Nonaktifkan'
                                            : 'Aktifkan'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}
