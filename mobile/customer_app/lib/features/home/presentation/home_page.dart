import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/auth/presentation/auth_bloc.dart';
import '../../../features/auth/domain/auth_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'Groceries';
  final Set<String> _wishlistedItems = {};

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Groceries', 'icon': Icons.shopping_basket},
    {'name': 'Electronics', 'icon': Icons.devices},
    {'name': 'Fashion', 'icon': Icons.dry_cleaning},
    {'name': 'Dining', 'icon': Icons.restaurant},
    {'name': 'Beauty', 'icon': Icons.spa},
  ];

  final List<Map<String, dynamic>> _popularProducts = [
    {
      'id': 'p1',
      'name': 'Aero-Flash Pro Running Shoes',
      'category': 'FASHION',
      'price': '120.00',
      'rating': '4.5',
      'colors': [Colors.deepOrange, Colors.orangeAccent],
      'icon': Icons.directions_run,
    },
    {
      'id': 'p2',
      'name': 'Noise-Cancelling Studio Headset',
      'category': 'ELECTRONICS',
      'price': '299.00',
      'rating': '4.8',
      'colors': [Colors.blueGrey[800]!, Colors.blueGrey[900]!],
      'icon': Icons.headphones,
    },
    {
      'id': 'p3',
      'name': 'Organic Hass Avocados (3pk)',
      'category': 'GROCERIES',
      'price': '4.50',
      'rating': '4.9',
      'colors': [Colors.green[700]!, Colors.green[900]!],
      'icon': Icons.eco,
    },
    {
      'id': 'p4',
      'name': 'Midnight Polarized Shades',
      'category': 'FASHION',
      'price': '85.00',
      'rating': '4.7',
      'colors': [Colors.amber[800]!, Colors.brown[900]!],
      'icon': Icons.sunny,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Header (Location, Marketplace Title, Profile Avatar) ─────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'New York, NY',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    // Title
                    const Text(
                      'Marketplace',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    // Profile Avatar
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!, width: 1.5),
                      ),
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(Icons.person, size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 2. Search & Filter Bar ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(width: 14),
                            Icon(Icons.search, color: Colors.grey, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Search stores or products...',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.tune, color: Colors.black87, size: 20),
                    ),
                  ],
                ),
              ),

              // ── 3. Horizontal Categories ───────────────────────────────────
              const SizedBox(height: 16),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat['name'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat['name']),
                      child: Container(
                        margin: const EdgeInsets.only(right: 20),
                        child: Column(
                          children: [
                            Container(
                              height: 54,
                              width: 54,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey[100],
                              ),
                              child: Icon(
                                cat['icon'],
                                color: isSelected ? Colors.white : Colors.black87,
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat['name'],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? AppColors.primary : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── 4. Featured Stores Heading & Carousel ──────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Stores',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/stores'),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 190,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFeaturedStoreCard(
                      context: context,
                      name: 'Green Leaf Organics',
                      tag: 'Grocery · 15-25 min',
                      rating: '4.8',
                      colors: [Colors.orange[400]!, Colors.orange[600]!],
                      isPartner: true,
                    ),
                    _buildFeaturedStoreCard(
                      context: context,
                      name: 'Tech Hub Solutions',
                      tag: 'Electronics · 20-30 min',
                      rating: '4.7',
                      colors: [Colors.blueGrey[400]!, Colors.blueGrey[600]!],
                      isPartner: false,
                    ),
                  ],
                ),
              ),

              // ── 5. Popular Products Grid ───────────────────────────────────
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  'Popular Products',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.72,
                ),
                itemCount: _popularProducts.length,
                itemBuilder: (context, index) {
                  final prod = _popularProducts[index];
                  final isWishlisted = _wishlistedItems.contains(prod['id']);
                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                    clipBehavior: Clip.antiAlias,
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image / Graphic Area
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: prod['colors'] as List<Color>,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    prod['icon'] as IconData,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 44,
                                  ),
                                ),
                              ),
                              // Wishlist heart
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isWishlisted) {
                                        _wishlistedItems.remove(prod['id']);
                                      } else {
                                        _wishlistedItems.add(prod['id']);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                                      color: isWishlisted ? Colors.red : Colors.grey[600],
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Content Area
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    prod['category'] as String,
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.orange, size: 10),
                                      const SizedBox(width: 2),
                                      Text(
                                        prod['rating'] as String,
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                prod['name'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '\$${prod['price']}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add_shopping_cart,
                                        color: Colors.white,
                                        size: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // ── 6. Free Delivery Promotional Banner ────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0B1B3D), Color(0xFF06122C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Free Delivery',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'On your first 3 orders above \$25. Limited time offer!',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC65100),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(100, 36),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {},
                              child: const Text(
                                'Claim Now',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Mock runner illustration
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_shipping_outlined,
                          color: Colors.orange,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedStoreCard({
    required BuildContext context,
    required String name,
    required String tag,
    required String rating,
    required List<Color> colors,
    required bool isPartner,
  }) {
    return GestureDetector(
      onTap: () => context.go('/stores/green-leaf-organics'),
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.storefront,
                        color: Colors.white.withOpacity(0.8),
                        size: 48,
                      ),
                    ),
                  ),
                  if (isPartner)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Partner',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 10),
                            const SizedBox(width: 2),
                            Text(
                              rating,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tag,
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
