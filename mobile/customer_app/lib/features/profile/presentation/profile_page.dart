import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/presentation/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state is AuthAuthenticated ? state.user : null;

          return SingleChildScrollView(
            child: Column(
              children: [
                // ── Header ───────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white24,
                            child: user?.avatarUrl != null
                                ? ClipOval(child: Image.network(user!.avatarUrl!, fit: BoxFit.cover))
                                : Text(
                                    (user?.name ?? 'U')[0].toUpperCase(),
                                    style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.w700),
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt_outlined, size: 18, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.name ?? 'Guest User',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      if (user?.isVerified == true) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text('Verified', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Stats row ─────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  color: AppColors.surface,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      _StatItem(value: '24', label: 'Orders'),
                      _Divider(),
                      _StatItem(value: '4.8', label: 'Rating'),
                      _Divider(),
                      _StatItem(value: '\$320', label: 'Spent'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Settings sections ─────────────────────────────────────
                _SettingsSection(
                  title: 'Account',
                  items: [
                    _SettingsItem(icon: Icons.person_outline, label: 'Personal Information', onTap: () {}),
                    _SettingsItem(icon: Icons.location_on_outlined, label: 'Saved Addresses', onTap: () {}),
                    _SettingsItem(icon: Icons.credit_card_outlined, label: 'Payment Methods', onTap: () {}),
                    _SettingsItem(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () {}),
                  ],
                ),

                const SizedBox(height: 16),

                _SettingsSection(
                  title: 'Support',
                  items: [
                    _SettingsItem(icon: Icons.help_outline, label: 'Help Center', onTap: () {}),
                    _SettingsItem(icon: Icons.chat_outlined, label: 'Contact Us', onTap: () {}),
                    _SettingsItem(icon: Icons.star_outline, label: 'Rate the App', onTap: () {}),
                    _SettingsItem(icon: Icons.policy_outlined, label: 'Privacy Policy', onTap: () {}),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Logout ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: ListTile(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Sign Out?'),
                            content: const Text('Are you sure you want to sign out?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.read<AuthBloc>().add(const AuthLogoutEvent());
                                  context.go(AppRoutes.login);
                                },
                                child: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                      },
                      leading: const Icon(Icons.logout, color: AppColors.error),
                      title: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: AppColors.outline);
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.items});
  final String title;
  final List<_SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(title, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant, letterSpacing: 1)),
            ),
            ...items,
          ],
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.onSurfaceVariant, size: 22),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant, size: 20),
      dense: true,
    );
  }
}
