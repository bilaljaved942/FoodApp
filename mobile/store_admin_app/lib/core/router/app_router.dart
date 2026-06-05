import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/home/presentation/store_dashboard_page.dart';
import '../../features/orders/presentation/store_orders_page.dart';
import '../../features/orders/presentation/store_order_detail_page.dart';
import '../../features/menu/presentation/menu_management_page.dart';
import '../../features/menu/presentation/add_edit_product_page.dart';
import '../../features/profile/presentation/store_profile_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const StoreDashboardPage(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const StoreOrdersPage(),
      ),
      GoRoute(
        path: '/orders/:orderId',
        builder: (context, state) => StoreOrderDetailPage(
          orderId: state.pathParameters['orderId'] ?? '4021',
        ),
      ),
      GoRoute(
        path: '/menu',
        builder: (context, state) => const MenuManagementPage(),
      ),
      GoRoute(
        path: '/menu/add-edit',
        builder: (context, state) => const AddEditProductPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const StoreProfilePage(),
      ),
    ],
  );
}
