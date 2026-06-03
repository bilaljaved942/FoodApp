import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';

class AddressPickerPage extends StatefulWidget {
  const AddressPickerPage({super.key});

  @override
  State<AddressPickerPage> createState() => _AddressPickerPageState();
}

class _AddressPickerPageState extends State<AddressPickerPage> {
  final _searchController = TextEditingController();
  int _selectedIndex = 0;

  static const _savedAddresses = [
    _Address(label: 'Home', address: '123 Main Street, Apt 4B', city: 'New York, NY 10001', icon: Icons.home_outlined),
    _Address(label: 'Work', address: '456 Office Park, Suite 200', city: 'New York, NY 10002', icon: Icons.work_outline),
    _Address(label: 'Gym', address: '789 Fitness Ave', city: 'Brooklyn, NY 11201', icon: Icons.fitness_center_outlined),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Address')),
      body: Column(
        children: [
          // ── Map Placeholder ──────────────────────────────────────────────
          Container(
            height: 200,
            color: AppColors.shimmer,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined, size: 48, color: Colors.white54),
                  SizedBox(height: 8),
                  Text('Map View', style: TextStyle(color: Colors.white54)),
                  Text('(Google Maps integration here)', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
          ),

          // ── Search bar ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a location…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Use current location ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              onTap: () {}, // TODO: get current location via geolocator
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.my_location, color: AppColors.primary, size: 20),
              ),
              title: const Text('Use current location', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Enable GPS to detect your location'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: AppColors.surface,
            ),
          ),

          const SizedBox(height: 16),

          // ── Saved Addresses ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Saved Addresses', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                TextButton.icon(
                  onPressed: () {}, // TODO: add new address
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add New'),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _savedAddresses.length,
              itemBuilder: (context, index) {
                final addr = _savedAddresses[index];
                final isSelected = _selectedIndex == index;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    onTap: () => setState(() => _selectedIndex = index),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(addr.icon, color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant, size: 20),
                    ),
                    title: Text(addr.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${addr.address}\n${addr.city}'),
                    isThreeLine: true,
                    trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                  ),
                );
              },
            ),
          ),

          // ── Confirm button ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              top: false,
              child: CustomButton(
                onPressed: () => Navigator.pop(context),
                label: 'Confirm Address',
                icon: Icons.location_on,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Address {
  const _Address({
    required this.label,
    required this.address,
    required this.city,
    required this.icon,
  });
  final String label;
  final String address;
  final String city;
  final IconData icon;
}
