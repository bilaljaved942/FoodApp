import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';

class StoreDetailPage extends StatefulWidget {
  const StoreDetailPage({super.key, required this.storeId});
  final String storeId;

  @override
  State<StoreDetailPage> createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const _tabs = ['Menu', 'Info', 'Reviews'];

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
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: AppColors.shimmer),
                  const Center(
                    child: Icon(Icons.restaurant, size: 64, color: Colors.white54),
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.onSurfaceVariant,
              indicatorWeight: 3,
            ),
          ),
        ],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store info header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Restaurant #${widget.storeId}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text('Pizza · Italian · Fast Food'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: AppColors.starFilled),
                      const SizedBox(width: 4),
                      const Text('4.5 (320 reviews)'),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      const Text('25–40 min'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _MenuTab(storeId: widget.storeId),
                  const _InfoTab(),
                  const _ReviewsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTab extends StatelessWidget {
  const _MenuTab({required this.storeId});
  final String storeId;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) => _MenuItemCard(index: index),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menu Item ${index + 1}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Delicious item description goes here.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${(index + 1) * 3 + 4}.99',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 90,
                    height: 90,
                    color: AppColors.shimmer,
                    child: const Icon(Icons.fastfood, color: Colors.white54),
                  ),
                ),
                Positioned(
                  bottom: -10,
                  right: 0,
                  child: CustomButton(
                    onPressed: () {},
                    label: '+',
                    minimumSize: const Size(36, 36),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(leading: Icon(Icons.location_on_outlined), title: Text('123 Main Street, City'), subtitle: Text('2.3 km away')),
        ListTile(leading: Icon(Icons.access_time_outlined), title: Text('Opening Hours'), subtitle: Text('Mon–Sun: 10:00 AM – 11:00 PM')),
        ListTile(leading: Icon(Icons.phone_outlined), title: Text('Contact'), subtitle: Text('+1 234 567 8900')),
        ListTile(leading: Icon(Icons.delivery_dining_outlined), title: Text('Delivery'), subtitle: Text('\$2.99 · Free above \$30')),
      ],
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab();
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(child: Icon(Icons.person)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(Icons.star, size: 14,
                                color: i < (4 + index % 2) ? AppColors.starFilled : AppColors.starEmpty),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text('${index + 1}d ago', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Great food and fast delivery! Would definitely order again.'),
            ],
          ),
        ),
      ),
    );
  }
}
