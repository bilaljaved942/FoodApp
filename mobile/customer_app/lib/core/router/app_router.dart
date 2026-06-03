import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/auth_bloc.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/cart/presentation/cart_page.dart';
import '../../features/checkout/presentation/address_picker_page.dart';
import '../../features/checkout/presentation/checkout_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/orders/presentation/order_tracking_page.dart';
import '../../features/orders/presentation/orders_list_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/stores/presentation/store_detail_page.dart';
import '../../features/stores/presentation/stores_list_page.dart';
import '../di/injection.dart';

/// Named route constants — use these instead of raw strings.
abstract class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String stores = '/stores';
  static const String storeDetail = '/stores/:storeId';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String addressPicker = '/checkout/address';
  static const String orders = '/orders';
  static const String orderTracking = '/orders/:orderId/tracking';
  static const String profile = '/profile';
}

/// Application-wide router configuration using go_router.
abstract class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: _globalRedirect,
    routes: [
      // ── Splash / Root redirect ───────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const _SplashRedirect(),
      ),

      // ── Auth ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => _fadeTransition(
          state: state,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const RegisterPage(),
        ),
      ),

      // ── Main Shell (with bottom nav) ──────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (_, __) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.stores,
            name: 'stores',
            builder: (_, __) => const StoresListPage(),
            routes: [
              GoRoute(
                path: ':storeId',
                name: 'storeDetail',
                builder: (context, state) => StoreDetailPage(
                  storeId: state.pathParameters['storeId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.cart,
            name: 'cart',
            builder: (_, __) => const CartPage(),
          ),
          GoRoute(
            path: AppRoutes.orders,
            name: 'orders',
            builder: (_, __) => const OrdersListPage(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (_, __) => const ProfilePage(),
          ),
        ],
      ),

      // ── Checkout (full-screen, outside shell) ─────────────────────────────
      GoRoute(
        path: AppRoutes.checkout,
        name: 'checkout',
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const CheckoutPage(),
        ),
        routes: [
          GoRoute(
            path: 'address',
            name: 'addressPicker',
            builder: (_, __) => const AddressPickerPage(),
          ),
        ],
      ),

      // ── Order Tracking ────────────────────────────────────────────────────
      GoRoute(
        path: '/orders/:orderId/tracking',
        name: 'orderTracking',
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: OrderTrackingPage(
            orderId: state.pathParameters['orderId']!,
          ),
        ),
      ),
    ],

    // ── Error Page ──────────────────────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error?.message}'),
      ),
    ),
  );

  // ─── Global redirect: gate everything behind auth ─────────────────────────
  static String? _globalRedirect(BuildContext context, GoRouterState state) {
    final authBloc = context.read<AuthBloc>();
    final isAuthenticated = authBloc.state is AuthAuthenticated;
    final isOnAuthPage = state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.register;

    if (!isAuthenticated && !isOnAuthPage) return AppRoutes.login;
    if (isAuthenticated && isOnAuthPage) return AppRoutes.home;
    return null;
  }

  // ─── Transition helpers ───────────────────────────────────────────────────
  static CustomTransitionPage<void> _fadeTransition({
    required GoRouterState state,
    required Widget child,
  }) =>
      CustomTransitionPage<void>(
        key: state.pageKey,
        child: child,
        transitionsBuilder: (_, animation, __, c) =>
            FadeTransition(opacity: animation, child: c),
      );

  static CustomTransitionPage<void> _slideTransition({
    required GoRouterState state,
    required Widget child,
  }) =>
      CustomTransitionPage<void>(
        key: state.pageKey,
        child: child,
        transitionsBuilder: (_, animation, __, c) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: c,
        ),
      );
}

// ─── Splash redirect widget ──────────────────────────────────────────────────
class _SplashRedirect extends StatelessWidget {
  const _SplashRedirect();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
        } else if (state is AuthUnauthenticated) {
          context.go(AppRoutes.login);
        }
      },
      child: const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

// ─── Main shell with bottom navigation ───────────────────────────────────────
class _MainShell extends StatelessWidget {
  const _MainShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    if (location.startsWith('/stores')) currentIndex = 1;
    if (location.startsWith('/cart')) currentIndex = 2;
    if (location.startsWith('/orders')) currentIndex = 3;
    if (location.startsWith('/profile')) currentIndex = 4;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (idx) {
          switch (idx) {
            case 0:
              context.go(AppRoutes.home);
            case 1:
              context.go(AppRoutes.stores);
            case 2:
              context.go(AppRoutes.cart);
            case 3:
              context.go(AppRoutes.orders);
            case 4:
              context.go(AppRoutes.profile);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.store_outlined), activeIcon: Icon(Icons.store), label: 'Stores'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
