import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class StoreDashboardPage extends StatefulWidget {
  const StoreDashboardPage({super.key});

  @override
  State<StoreDashboardPage> createState() => _StoreDashboardPageState();
}

class _StoreDashboardPageState extends State<StoreDashboardPage> {
  bool _isStoreOpen = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Store Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          Row(
            children: [
              Text(
                _isStoreOpen ? 'OPEN' : 'CLOSED',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Switch(
                value: _isStoreOpen,
                activeColor: Colors.white,
                activeTrackColor: Colors.green[400],
                inactiveThumbColor: Colors.white70,
                inactiveTrackColor: Colors.red[300],
                onChanged: (val) => setState(() => _isStoreOpen = val),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Store details quick card ───────────────────────────
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                      child: const Icon(Icons.storefront, size: 32, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Green Leaf Organics',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Partner Store · Grocery',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Stats Row ──────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Today\'s Sales',
                    value: '\$432.80',
                    subtitle: '+12% from yesterday',
                    icon: Icons.monetization_on,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Active Orders',
                    value: '6 Orders',
                    subtitle: '2 pending prep',
                    icon: Icons.shopping_bag,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Sales Mini-Chart (Native drawing) ──────────────────
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Weekly Revenue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildBar('Mon', 45),
                          _buildBar('Tue', 70),
                          _buildBar('Wed', 55),
                          _buildBar('Thu', 85),
                          _buildBar('Fri', 110),
                          _buildBar('Sat', 95),
                          _buildBar('Sun', 60),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Quick Action Panel ──────────────────────────────────
            const Text(
              'Quick Management',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildQuickAction(
                  label: 'Manage Orders',
                  icon: Icons.receipt_long,
                  color: AppColors.primary,
                  onTap: () => context.go('/orders'),
                ),
                _buildQuickAction(
                  label: 'Manage Menu',
                  icon: Icons.restaurant_menu,
                  color: Colors.teal,
                  onTap: () => context.go('/menu'),
                ),
                _buildQuickAction(
                  label: 'Store Profile',
                  icon: Icons.store,
                  color: Colors.indigo,
                  onTap: () => context.go('/profile'),
                ),
                _buildQuickAction(
                  label: 'Analytics',
                  icon: Icons.bar_chart,
                  color: Colors.blueGrey,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Icon(icon, size: 20, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.green[700])),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String label, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(6),
            gradient: const LinearGradient(
              colors: [AppColors.primaryLight, AppColors.primary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildQuickAction({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
