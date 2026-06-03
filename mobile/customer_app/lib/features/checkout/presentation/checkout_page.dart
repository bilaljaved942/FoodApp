import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../cart/domain/cart_bloc.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedPayment = 'card';
  bool _isPlacingOrder = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ── Delivery Address ──────────────────────────────────
                    _SectionCard(
                      title: 'Delivery Address',
                      trailing: TextButton(
                        onPressed: () => context.push(AppRoutes.addressPicker),
                        child: const Text('Change'),
                      ),
                      child: const ListTile(
                        leading: Icon(Icons.location_on, color: AppColors.primary),
                        title: Text('123 Main Street, Apt 4B'),
                        subtitle: Text('New York, NY 10001'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Delivery Time ─────────────────────────────────────
                    _SectionCard(
                      title: 'Estimated Delivery',
                      child: const Row(
                        children: [
                          Icon(Icons.access_time, color: AppColors.primary, size: 20),
                          SizedBox(width: 12),
                          Text('25–40 minutes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Payment Method ────────────────────────────────────
                    _SectionCard(
                      title: 'Payment Method',
                      child: Column(
                        children: [
                          _PaymentOption(
                            label: 'Credit / Debit Card',
                            icon: Icons.credit_card,
                            value: 'card',
                            groupValue: _selectedPayment,
                            onChanged: (v) => setState(() => _selectedPayment = v!),
                          ),
                          _PaymentOption(
                            label: 'Cash on Delivery',
                            icon: Icons.money,
                            value: 'cash',
                            groupValue: _selectedPayment,
                            onChanged: (v) => setState(() => _selectedPayment = v!),
                          ),
                          _PaymentOption(
                            label: 'Wallet Balance',
                            icon: Icons.account_balance_wallet_outlined,
                            value: 'wallet',
                            groupValue: _selectedPayment,
                            onChanged: (v) => setState(() => _selectedPayment = v!),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Coupon ────────────────────────────────────────────
                    _SectionCard(
                      title: 'Promo Code',
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter promo code',
                          suffixIcon: TextButton(
                            onPressed: () {},
                            child: const Text('Apply'),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Order Summary ─────────────────────────────────────
                    _SectionCard(
                      title: 'Order Summary',
                      child: Column(
                        children: [
                          _SummaryRow('Items (${cartState.totalItems})', '\$${cartState.subtotal.toStringAsFixed(2)}'),
                          const SizedBox(height: 6),
                          _SummaryRow('Delivery', cartState.deliveryFee == 0 ? 'FREE' : '\$${cartState.deliveryFee.toStringAsFixed(2)}'),
                          const SizedBox(height: 6),
                          _SummaryRow('Service fee', '\$${cartState.serviceFee.toStringAsFixed(2)}'),
                          const Divider(height: 16),
                          _SummaryRow('Total', '\$${cartState.total.toStringAsFixed(2)}', isBold: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // ── Place Order ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: CustomButton(
                    onPressed: _isPlacingOrder ? null : _placeOrder,
                    label: 'Place Order · \$${cartState.total.toStringAsFixed(2)}',
                    icon: Icons.check_circle_outline,
                    isLoading: _isPlacingOrder,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _placeOrder() async {
    setState(() => _isPlacingOrder = true);
    // TODO: call order API
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isPlacingOrder = false);
      context.read<CartBloc>().add(const CartClearEvent());
      context.go(AppRoutes.orders);
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });
  final String label;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {this.isBold = false});
  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: isBold ? FontWeight.w700 : FontWeight.w400)),
        Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.w700 : FontWeight.w400, color: isBold ? AppColors.primary : null, fontSize: isBold ? 16 : 14)),
      ],
    );
  }
}
