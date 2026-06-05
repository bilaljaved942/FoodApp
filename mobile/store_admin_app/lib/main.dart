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

import 'core/storage/storage_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('StoreAdmin: background FCM message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Hive.initFlutter();
  await configureDependencies();
  await getIt<StorageService>().init();
  runApp(const StoreAdminApp());
}

class StoreAdminApp extends StatelessWidget {
  const StoreAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(AuthCheckStatusEvent()),
        ),
      ],
      child: MaterialApp.router(
        title: 'FoodApp Store',
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
                  '/orders',
                  '/orders/4021',
                  '/menu',
                  '/menu/add-edit',
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
