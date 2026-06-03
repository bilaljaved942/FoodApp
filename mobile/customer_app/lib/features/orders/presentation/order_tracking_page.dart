import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({super.key, required this.orderId});
  final String orderId;

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  // Simulated current step (0-indexed)
  final int _currentStep = 2;

  static const _steps = [
    _TrackingStep(label: 'Order Placed', icon: Icons.check_circle_outline, description: 'Your order has been received'),
    _TrackingStep(label: 'Confirmed', icon: Icons.store_outlined, description: 'The restaurant confirmed your order'),
    _TrackingStep(label: 'Preparing', icon: Icons.restaurant_outlined, description: 'The chef is preparing your food'),
    _TrackingStep(label: 'On the way', icon: Icons.delivery_dining_outlined, description: 'Rider is heading to you'),
    _TrackingStep(label: 'Delivered', icon: Icons.home_outlined, description: 'Enjoy your meal!'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order #${widget.orderId}')),
      body: Column(
        children: [
          // ── Map placeholder ─────────────────────────────────────────────
          Container(
            height: 220,
            color: AppColors.shimmer,
            child: Stack(
              children: [
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map_outlined, size: 48, color: Colors.white54),
                      SizedBox(height: 8),
                      Text('Live Tracking Map', style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                ),
                // Rider indicator
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delivery_dining, color: AppColors.primary, size: 18),
                          SizedBox(width: 8),
                          Text('Rider is 1.2 km away · ~8 min', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Status header ─────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.restaurant_outlined, size: 14, color: AppColors.warning),
                            SizedBox(width: 6),
                            Text('Preparing', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Text('Est. 25 min', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text('Order Progress', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),

                  // ── Tracking steps ───────────────────────────────────
                  ...List.generate(_steps.length, (index) {
                    final step = _steps[index];
                    final isCompleted = index <= _currentStep;
                    final isCurrent = index == _currentStep;
                    final isLast = index == _steps.length - 1;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? (isCurrent ? AppColors.primary : AppColors.success)
                                    : AppColors.surfaceVariant,
                                shape: BoxShape.circle,
                                border: isCurrent
                                    ? Border.all(color: AppColors.primary, width: 2)
                                    : null,
                              ),
                              child: Icon(
                                step.icon,
                                size: 20,
                                color: isCompleted ? Colors.white : AppColors.onSurfaceVariant,
                              ),
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 50,
                                color: isCompleted && index < _currentStep
                                    ? AppColors.success
                                    : AppColors.outline,
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 26),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step.label,
                                  style: TextStyle(
                                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                                    color: isCompleted
                                        ? (isCurrent ? AppColors.primary : AppColors.onSurface)
                                        : AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  step.description,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 16),

                  // ── Rider info ─────────────────────────────────────────
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: const Text('Marcus Johnson', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Your delivery rider'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.phone_outlined, color: AppColors.primary),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.chat_outlined, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingStep {
  const _TrackingStep({required this.label, required this.icon, required this.description});
  final String label;
  final IconData icon;
  final String description;
}
