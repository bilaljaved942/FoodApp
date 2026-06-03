import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  String _selectedPeriod = 'Week';
  static const _periods = ['Today', 'Week', 'Month', 'All Time'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Period selector ──────────────────────────────────────────
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  // Main earning display
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Text('Total Earned', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        SizedBox(height: 4),
                        Text('\$284.50', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w700)),
                        SizedBox(height: 4),
                        Text('42 deliveries this week', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  // Period tabs
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: _periods.map((p) {
                        final isSelected = p == _selectedPeriod;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPeriod = p),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(p,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected ? AppColors.primary : Colors.white,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                    fontSize: 13,
                                  )),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // ── Stats row ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Expanded(child: _EarningStatCard(label: 'Deliveries', value: '42', icon: Icons.delivery_dining_outlined)),
                  SizedBox(width: 12),
                  Expanded(child: _EarningStatCard(label: 'Avg per Delivery', value: '\$6.77', icon: Icons.trending_up_outlined)),
                  SizedBox(width: 12),
                  Expanded(child: _EarningStatCard(label: 'Tips', value: '\$38.20', icon: Icons.favorite_outline)),
                ],
              ),
            ),

            // ── Transaction history ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Transactions', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  TextButton(onPressed: () {}, child: const Text('See all')),
                ],
              ),
            ),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 8,
              itemBuilder: (context, index) => _TransactionTile(index: index),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _EarningStatCard extends StatelessWidget {
  const _EarningStatCard({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.primary)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.success.withOpacity(0.15),
          child: const Icon(Icons.delivery_dining, color: AppColors.success, size: 20),
        ),
        title: Text('Order #ORD-${300 + index}', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${index + 1} day${index > 0 ? 's' : ''} ago · ${index + 2} km'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('+\$${(index + 1) * 3 + 4}.50', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
            if (index % 3 == 0)
              const Text('+\$2.00 tip', style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
