import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'auth/providers/auth_provider.dart';
import 'auth/screens/login_screen.dart';
import 'auth/screens/register_screen.dart';
import 'auth/widgets/admin_gate.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/app_settings_provider.dart';
import 'admin/screens/admin_panel_screen.dart';
import 'cart/providers/cart_provider.dart';
import 'cart/screens/cart_screen.dart';
import 'cart/widgets/no_overscroll_behavior.dart';
import 'checkout/screens/checkout_screen.dart';
import 'checkout/screens/order_success_screen.dart';
import 'history/screens/order_detail_page.dart';
import 'history/screens/order_history_page.dart';
import 'notification/providers/notification_provider.dart';
import 'notification/screens/notification_page.dart';
import 'notification/services/notification_service.dart';
import 'product/providers/favorite_provider.dart';
import 'product/providers/product_provider.dart';
import 'product/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  await NotificationService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider milik Fiji (Cart & Checkout)
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),

        // Provider modul Product & Shopping (kita)
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),

        // Provider auth untuk login dan role
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()..load()),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'BlueMart Retail',
            debugShowCheckedModeBanner: false,
            scrollBehavior: const NoOverscrollBehavior(),
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            themeAnimationDuration: const Duration(milliseconds: 260),
            themeAnimationCurve: Curves.easeOutCubic,
            home: const LoginScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const ProductHomeScreen(),
              '/cart': (context) => const CartScreen(),
              '/checkout': (context) => const CheckoutScreen(),
              '/order-success': (context) => const OrderSuccessScreen(),
              '/orders': (context) => const OrderHistoryPage(),
              '/notifications': (context) => const NotificationPage(),
              '/admin': (context) => const AdminGate(child: AdminPanelScreen()),
              '/register': (context) => const RegisterScreen(),
              '/order-detail': (context) {
                final arg = ModalRoute.of(context)?.settings.arguments;
                return OrderDetailPage(orderId: arg is int ? arg : 0);
              },
            },
          );
        },
      ),
    );
  }
}
