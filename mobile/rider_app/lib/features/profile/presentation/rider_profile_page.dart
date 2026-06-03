import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/presentation/auth_bloc.dart';

class RiderProfilePage extends StatelessWidget {
  const RiderProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state is AuthAuthenticated ? state.user : null;
          return SingleChildScrollView(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFBF360C), Color(0xFFFF5722)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white24,
                        child: Text(
                          (user?.name ?? 'R')[0].toUpperCase(),
                          style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(user?.name ?? 'Rider', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(user?.email ?? '', style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('${user?.rating.toStringAsFixed(1) ?? '4.9'} Rating',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Vehicle info ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Vehicle Information', style: TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          const ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.two_wheeler, color: AppColors.primary),
                            title: Text('Honda CB300R'),
                            subtitle: Text('License: XYZ-1234'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Settings ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Column(
                      children: [
                        _SettingsTile(icon: Icons.person_outline, label: 'Personal Info', onTap: () {}),
                        _SettingsTile(icon: Icons.account_balance_outlined, label: 'Bank Account', onTap: () {}),
                        _SettingsTile(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () {}),
                        _SettingsTile(icon: Icons.help_outline, label: 'Support', onTap: () {}),
                        _SettingsTile(
                          icon: Icons.logout,
                          label: 'Sign Out',
                          onTap: () {
                            context.read<AuthBloc>().add(const AuthLogoutEvent());
                            context.go(AppRoutes.login);
                          },
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.label, required this.onTap, this.isDestructive = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.onSurfaceVariant, size: 22),
      title: Text(label, style: TextStyle(color: isDestructive ? AppColors.error : null, fontWeight: isDestructive ? FontWeight.w600 : null)),
      trailing: isDestructive ? null : const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant, size: 20),
    );
  }
}
