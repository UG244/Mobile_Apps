import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart/providers/cart_provider.dart';
import 'cart/screens/cart_screen.dart';
import 'cart/widgets/no_overscroll_behavior.dart';
import 'checkout/screens/checkout_screen.dart';
import 'checkout/screens/order_history_screen.dart';
import 'checkout/screens/order_success_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MaterialApp(
        title: 'Piranti Bergerak',
        debugShowCheckedModeBanner: false,
        scrollBehavior: const NoOverscrollBehavior(),
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5F7FA),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            primary: const Color(0xFF1565C0),
            secondary: const Color(0xFF42A5F5),
            surface: Colors.white,
            brightness: Brightness.light,
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        home: const HomeScreen(),
        routes: {
          '/cart': (context) => const CartScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/order-success': (context) => const OrderSuccessScreen(),
          '/orders': (context) => const OrderHistoryScreen(),
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BlueMart Retail'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Halaman Home',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/cart'),
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text('Lihat Keranjang'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/checkout'),
              icon: const Icon(Icons.payment_outlined),
              label: const Text('Checkout Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}
