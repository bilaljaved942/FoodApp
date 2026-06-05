import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class StoreOrderDetailPage extends StatelessWidget {
  const StoreOrderDetailPage({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Order Details #$orderId', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/orders'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Customer Details Card ──────────────────────────────
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CUSTOMER DETAILS', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
                    SizedBox(height: 12),
                    Text('John Doe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text('+1 (555) 123-4567', style: TextStyle(fontSize: 14)),
                    SizedBox(height: 4),
                    Text('Apt 4B, 100 Main Street, New York, NY', style: TextStyle(fontSize: 13, color: Colors.black87)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Items Card ─────────────────────────────────────────
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ORDER ITEMS', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
                    const SizedBox(height: 12),
                    _buildItemRow('2x Organic Hass Avocados', '\$9.00'),
                    _buildItemRow('1x Apple Cider Vinegar', '\$6.50'),
                    _buildItemRow('1x Fresh Bananas Bunch', '\$3.00'),
                    const Divider(height: 32),
                    _buildSummaryRow('Subtotal', '\$18.50'),
                    _buildSummaryRow('Delivery Fee', '\$2.99'),
                    _buildSummaryRow('Tax', '\$1.50'),
                    const Divider(height: 24),
                    _buildSummaryRow('Total', '\$22.99', isBold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Delivery Rider Card ────────────────────────────────
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DELIVERY RIDER', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: const Icon(Icons.person, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Marcus Vance', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('Active Delivery Partner', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.phone, color: AppColors.primary),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Update Action Buttons ──────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {},
                    child: const Text('Cancel Order', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {},
                    child: const Text('Mark Preparing', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(String name, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 14)),
          Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? AppColors.primary : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
