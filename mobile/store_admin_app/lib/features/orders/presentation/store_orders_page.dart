import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class StoreOrdersPage extends StatefulWidget {
  const StoreOrdersPage({super.key});

  @override
  State<StoreOrdersPage> createState() => _StoreOrdersPageState();
}

class _StoreOrdersPageState extends State<StoreOrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Pending (2)', 'Preparing (3)', 'Ready (1)', 'Completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Store Orders', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList('Pending'),
          _buildOrdersList('Preparing'),
          _buildOrdersList('Ready'),
          _buildOrdersList('Completed'),
        ],
      ),
    );
  }

  Widget _buildOrdersList(String status) {
    // Generate dummy orders based on status
    final List<Map<String, dynamic>> dummyOrders;
    if (status == 'Pending') {
      dummyOrders = [
        {'id': '#4021', 'time': '3 mins ago', 'items': '2x Organic Hass Avocados, 1x Apple Cider Vinegar', 'total': '\$18.50'},
        {'id': '#4022', 'time': '5 mins ago', 'items': '1x Aero-Flash Pro Running Shoes', 'total': '\$120.00'},
      ];
    } else if (status == 'Preparing') {
      dummyOrders = [
        {'id': '#4018', 'time': '12 mins ago', 'items': '1x Studio Headset, 2x Micro USB Cable', 'total': '\$315.00'},
        {'id': '#4019', 'time': '15 mins ago', 'items': '3x Midnight Polarized Shades', 'total': '\$255.00'},
        {'id': '#4020', 'time': '20 mins ago', 'items': '1x Fresh Watermelon (Whole)', 'total': '\$9.00'},
      ];
    } else if (status == 'Ready') {
      dummyOrders = [
        {'id': '#4015', 'time': '30 mins ago', 'items': '4x Organic Hass Avocados, 2x Bananas Bunch', 'total': '\$21.40'},
      ];
    } else {
      dummyOrders = [
        {'id': '#4009', 'time': 'Yesterday', 'items': '1x Aero-Flash Pro Running Shoes', 'total': '\$120.00'},
        {'id': '#4010', 'time': 'Yesterday', 'items': '2x Noise-Cancelling Studio Headset', 'total': '\$598.00'},
      ];
    }

    if (dummyOrders.isEmpty) {
      return const Center(child: Text('No orders in this section'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dummyOrders.length,
      itemBuilder: (context, index) {
        final order = dummyOrders[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order ${order['id']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      order['time'],
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  order['items'],
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${order['total']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                    ),
                    TextButton(
                      onPressed: () => context.go('/orders/${order['id'].substring(1)}'),
                      child: const Row(
                        children: [
                          Text('Details', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: _buildActionButtons(status),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildActionButtons(String status) {
    if (status == 'Pending') {
      return [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            foregroundColor: Colors.red,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {},
          child: const Text('Decline'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {},
          child: const Text('Accept'),
        ),
      ];
    } else if (status == 'Preparing') {
      return [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {},
          child: const Text('Mark as Ready'),
        ),
      ];
    } else if (status == 'Ready') {
      return [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {},
          child: const Text('Call Rider'),
        ),
      ];
    } else {
      return [
        const Icon(Icons.check_circle, color: Colors.green),
        const SizedBox(width: 4),
        const Text('Delivered', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
      ];
    }
  }
}
