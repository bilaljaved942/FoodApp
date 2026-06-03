import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_bloc.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/home/presentation/rider_home_page.dart';
import '../../features/orders/presentation/available_orders_page.dart';
import '../../features/orders/presentation/active_order_page.dart';
import '../../features/orders/presentation/delivery_map_page.dart';
import '../../features/earnings/presentation/earnings_page.dart';
import '../../features/profile/presentation/rider_profile_page.dart';

abstract class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String availableOrders = '/orders/available';
  static const String activeOrder = '/orders/active';
  static const String deliveryMap = '/orders/:orderId/map';
  static const String earnings = '/earnings';
  static const String profile = '/profile';
}

abstract class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: _globalRedirect,
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const _SplashRedirect()),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const LoginPage(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => _RiderShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.home, builder: (_, __) => const RiderHomePage()),
          GoRoute(path: AppRoutes.availableOrders, builder: (_, __) => const AvailableOrdersPage()),
          GoRoute(path: AppRoutes.earnings, builder: (_, __) => const EarningsPage()),
          GoRoute(path: AppRoutes.profile, builder: (_, __) => const RiderProfilePage()),
        ],
      ),
      GoRoute(
        path: AppRoutes.activeOrder,
        builder: (_, __) => const ActiveOrderPage(),
      ),
      GoRoute(
        path: '/orders/:orderId/map',
        builder: (context, state) => DeliveryMapPage(orderId: state.pathParameters['orderId']!),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(body: Center(child: Text('Not found: ${state.error}'))),
  );

  static String? _globalRedirect(BuildContext context, GoRouterState state) {
    final authBloc = context.read<AuthBloc>();
    final isAuthenticated = authBloc.state is AuthAuthenticated;
    final isOnLogin = state.matchedLocation == AppRoutes.login;
    if (!isAuthenticated && !isOnLogin) return AppRoutes.login;
    if (isAuthenticated && isOnLogin) return AppRoutes.home;
    return null;
  }
}

class _SplashRedirect extends StatelessWidget {
  const _SplashRedirect();
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) context.go(AppRoutes.home);
        else if (state is AuthUnauthenticated) context.go(AppRoutes.login);
      },
      child: const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}

class _RiderShell extends StatelessWidget {
  const _RiderShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    int idx = 0;
    if (location.startsWith('/orders')) idx = 1;
    if (location.startsWith('/earnings')) idx = 2;
    if (location.startsWith('/profile')) idx = 3;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) {
          switch (i) {
            case 0: context.go(AppRoutes.home);
            case 1: context.go(AppRoutes.availableOrders);
            case 2: context.go(AppRoutes.earnings);
            case 3: context.go(AppRoutes.profile);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), activeIcon: Icon(Icons.list_alt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'Earnings'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
