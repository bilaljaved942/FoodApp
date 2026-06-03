import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/presentation/auth_bloc.dart';

class RiderHomePage extends StatefulWidget {
  const RiderHomePage({super.key});

  @override
  State<RiderHomePage> createState() => _RiderHomePageState();
}

class _RiderHomePageState extends State<RiderHomePage> {
  bool _isOnline = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFBF360C), Color(0xFFFF5722)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final name = state is AuthAuthenticated ? state.user.name.split(' ').first : 'Rider';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Hey $name! 🛵', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 4),
                        const Text('Ready to deliver?', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ── Online toggle ──────────────────────────────────────
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _isOnline ? AppColors.success.withOpacity(0.15) : AppColors.surfaceVariant,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.delivery_dining, color: _isOnline ? AppColors.success : AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_isOnline ? 'You are Online' : 'You are Offline',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                Text(_isOnline ? 'Ready to receive orders' : 'Go online to start earning',
                                    style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isOnline,
                            onChanged: (v) => setState(() => _isOnline = v),
                            activeColor: AppColors.success,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Today stats ────────────────────────────────────────
                  Row(
                    children: const [
                      Expanded(child: _StatCard(label: "Today's Earnings", value: '\$48.50', icon: Icons.account_balance_wallet_outlined)),
                      SizedBox(width: 12),
                      Expanded(child: _StatCard(label: 'Deliveries', value: '7', icon: Icons.check_circle_outline)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: const [
                      Expanded(child: _StatCard(label: 'Distance', value: '32.4 km', icon: Icons.route_outlined)),
                      SizedBox(width: 12),
                      Expanded(child: _StatCard(label: 'Rating', value: '4.9 ⭐', icon: Icons.star_outline)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Recent activity ────────────────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Recent Deliveries', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(3, (i) => _RecentDeliveryTile(index: i)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _RecentDeliveryTile extends StatelessWidget {
  const _RecentDeliveryTile({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Color(0xFFF5F5F5), child: Icon(Icons.delivery_dining, color: AppColors.primary)),
        title: Text('Order #ORD-${100 + index}', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${index + 1}.${index * 3 + 2} km · ${index * 4 + 12} min ago'),
        trailing: Text('\$${(index + 1) * 4 + 6}.50', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
