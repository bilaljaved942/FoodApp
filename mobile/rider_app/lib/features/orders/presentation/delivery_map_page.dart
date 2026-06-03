import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class DeliveryMapPage extends StatelessWidget {
  const DeliveryMapPage({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Navigate · $orderId')),
      body: Stack(
        children: [
          // ── Map placeholder ──────────────────────────────────────────
          Container(
            color: AppColors.shimmer,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined, size: 64, color: Colors.white54),
                  SizedBox(height: 12),
                  Text('Google Maps Navigation', style: TextStyle(color: Colors.white54, fontSize: 16)),
                  Text('(google_maps_flutter integration here)', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
          ),

          // ── Bottom sheet navigation card ─────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outline, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.location_on, color: AppColors.primary),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Delivering to', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                              Text('456 Oak Avenue, Apt 3C', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                              Text('1.8 km · Est. 8 min away', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {}, // TODO: open google maps navigation
                        icon: const Icon(Icons.navigation_outlined),
                        label: const Text('Start Navigation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
            ),
          ),
        ],
      ),
    );
  }
}
