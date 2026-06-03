import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/error_widget.dart';
import '../domain/cart_bloc.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) => state.isEmpty
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Clear Cart?'),
                          content: const Text('All items will be removed from your cart.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () {
                                context.read<CartBloc>().add(const CartClearEvent());
                                Navigator.pop(context);
                              },
                              child: const Text('Clear', style: TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Clear'),
                  ),
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              message: 'Browse restaurants and add items to your cart.',
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return _CartItemCard(item: item);
                  },
                ),
              ),

              // ── Order Summary ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      _SummaryRow('Subtotal', '\$${state.subtotal.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        'Delivery fee',
                        state.deliveryFee == 0 ? 'FREE' : '\$${state.deliveryFee.toStringAsFixed(2)}',
                        valueColor: state.deliveryFee == 0 ? AppColors.success : null,
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow('Service fee', '\$${state.serviceFee.toStringAsFixed(2)}'),
                      if (state.discount > 0) ...[
                        const SizedBox(height: 8),
                        _SummaryRow('Discount', '-\$${state.discount.toStringAsFixed(2)}',
                            valueColor: AppColors.success),
                      ],
                      const Divider(height: 24),
                      _SummaryRow(
                        'Total',
                        '\$${state.total.toStringAsFixed(2)}',
                        isBold: true,
                        fontSize: 18,
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        onPressed: () => context.push(AppRoutes.checkout),
                        label: 'Proceed to Checkout',
                        icon: Icons.arrow_forward,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 70,
                height: 70,
                color: AppColors.shimmer,
                child: const Icon(Icons.fastfood, color: Colors.white54),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            // Quantity controls
            Row(
              children: [
                _CircleIconButton(
                  icon: Icons.remove,
                  onTap: () => context.read<CartBloc>().add(
                        CartUpdateQuantityEvent(
                            itemId: item.id, quantity: item.quantity - 1),
                      ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
                _CircleIconButton(
                  icon: Icons.add,
                  onTap: () => context.read<CartBloc>().add(
                        CartUpdateQuantityEvent(
                            itemId: item.id, quantity: item.quantity + 1),
                      ),
                  isPrimary: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap, this.isPrimary = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.surfaceVariant,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: isPrimary ? Colors.white : AppColors.onSurface),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {this.isBold = false, this.fontSize = 14, this.valueColor});
  final String label;
  final String value;
  final bool isBold;
  final double fontSize;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style.copyWith(color: isBold ? null : AppColors.onSurfaceVariant)),
        Text(value, style: style.copyWith(color: valueColor ?? (isBold ? AppColors.primary : null))),
      ],
    );
  }
}
