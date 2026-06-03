import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/error_widget.dart';

class OrdersListPage extends StatelessWidget {
  const OrdersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ActiveOrdersTab(),
            _OrderHistoryTab(),
          ],
        ),
      ),
    );
  }
}

class _ActiveOrdersTab extends StatelessWidget {
  const _ActiveOrdersTab();

  @override
  Widget build(BuildContext context) {
    // TODO: Load from BLoC
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 2,
      itemBuilder: (context, index) => _OrderCard(
        orderId: 'ORD-00${index + 1}',
        status: index == 0 ? 'On the way' : 'Preparing',
        statusColor: index == 0 ? AppColors.success : AppColors.warning,
        storeName: 'Restaurant ${index + 1}',
        items: '${index + 2} items',
        total: '\$${(index + 1) * 18.5}',
        time: '${20 + index * 10} min',
        isActive: true,
      ),
    );
  }
}

class _OrderHistoryTab extends StatelessWidget {
  const _OrderHistoryTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) => _OrderCard(
        orderId: 'ORD-${100 + index}',
        status: index % 4 == 3 ? 'Cancelled' : 'Delivered',
        statusColor: index % 4 == 3 ? AppColors.error : AppColors.success,
        storeName: 'Restaurant ${index + 3}',
        items: '${index + 1} items',
        total: '\$${(index + 1) * 12.0}',
        time: '${index + 1} day${index > 0 ? 's' : ''} ago',
        isActive: false,
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.orderId,
    required this.status,
    required this.statusColor,
    required this.storeName,
    required this.items,
    required this.total,
    required this.time,
    required this.isActive,
  });

  final String orderId;
  final String status;
  final Color statusColor;
  final String storeName;
  final String items;
  final String total;
  final String time;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(orderId,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.store_outlined, size: 16, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(storeName, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.receipt_outlined, size: 16, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 6),
                Text('$items · $total'),
                const Spacer(),
                const Icon(Icons.access_time, size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(time,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
            if (isActive) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {}, // navigate to tracking
                      icon: const Icon(Icons.map_outlined, size: 16),
                      label: const Text('Track Order'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        minimumSize: const Size(0, 40),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {}, // reorder
                icon: const Icon(Icons.replay_outlined, size: 16),
                label: const Text('Reorder'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  minimumSize: const Size(0, 40),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
