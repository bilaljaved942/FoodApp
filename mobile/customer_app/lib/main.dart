import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/router/dev_navigation_overlay.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_bloc.dart';
import 'features/cart/domain/cart_bloc.dart';

import 'core/storage/storage_service.dart';

/// Top-level handler for background FCM messages.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling background FCM message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialisation
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Hive local storage
  await Hive.initFlutter();

  // Dependency injection
  await configureDependencies();
  await getIt<StorageService>().init();

  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()..add(AuthCheckStatusEvent())),
        BlocProvider<CartBloc>(create: (_) => getIt<CartBloc>()),
      ],
      child: MaterialApp.router(
        title: 'FoodApp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
        builder: (context, child) {
          return Stack(
            children: [
              if (child != null) child,
              const DevNavigationOverlay(
                routes: [
                  '/login',
                  '/register',
                  '/home',
                  '/stores',
                  '/stores/green-leaf-organics',
                  '/cart',
                  '/checkout',
                  '/checkout/address',
                  '/orders',
                  '/orders/123/tracking',
                  '/profile',
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
