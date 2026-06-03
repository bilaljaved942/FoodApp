import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';

class ActiveOrderPage extends StatelessWidget {
  const ActiveOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Delivery')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Order status card ──────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Order #ORD-204', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Preparing', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _StepIndicator(
                      steps: const ['Pick Up', 'On the Way', 'Delivered'],
                      currentStep: 0,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Pickup location ────────────────────────────────────────
            Card(
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: Color(0xFFFFF3E0), shape: BoxShape.circle),
                  child: const Icon(Icons.store_outlined, color: AppColors.warning, size: 20),
                ),
                title: const Text('Pick Up', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Restaurant Pizza Palace\n123 Main Street, NY'),
                isThreeLine: true,
                trailing: IconButton(icon: const Icon(Icons.map_outlined, color: AppColors.primary), onPressed: () => context.push('/orders/ORD-204/map')),
              ),
            ),

            const SizedBox(height: 12),

            // ── Delivery location ──────────────────────────────────────
            Card(
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                ),
                title: const Text('Deliver To', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('John Doe\n456 Oak Avenue, Apt 3C, NY'),
                isThreeLine: true,
                trailing: IconButton(icon: const Icon(Icons.phone_outlined, color: AppColors.primary), onPressed: () {}),
              ),
            ),

            const SizedBox(height: 16),

            // ── Order items ────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order Items', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ...List.generate(3, (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('${i + 1}x Item ${i + 1}'), Text('\$${(i + 1) * 8}.99')],
                      ),
                    )),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
                        Text('\$42.96', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Actions ────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark as Picked Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.steps, required this.currentStep});
  final List<String> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;
        final isLast = index == steps.length - 1;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted ? AppColors.success : (isCurrent ? AppColors.primary : AppColors.surfaceVariant),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : Icons.circle,
                        size: 16,
                        color: (isCompleted || isCurrent) ? Colors.white : AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(steps[index], style: TextStyle(fontSize: 10, fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400, color: isCurrent ? AppColors.primary : AppColors.onSurfaceVariant), textAlign: TextAlign.center),
                  ],
                ),
              ),
              if (!isLast) Expanded(child: Divider(color: isCompleted ? AppColors.success : AppColors.outline, thickness: 2)),
            ],
          ),
        );
      }),
    );
  }
}
