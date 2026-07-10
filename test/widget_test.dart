import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:piranti_bergerak/auth/providers/auth_provider.dart';
import 'package:piranti_bergerak/cart/providers/cart_provider.dart';
import 'package:piranti_bergerak/cart/screens/cart_screen.dart';
import 'package:piranti_bergerak/checkout/screens/checkout_screen.dart';
import 'package:piranti_bergerak/notification/providers/notification_provider.dart';
import 'package:piranti_bergerak/product/db/product_db.dart';
import 'package:piranti_bergerak/product/providers/favorite_provider.dart';
import 'package:piranti_bergerak/product/providers/product_provider.dart';
import 'package:piranti_bergerak/product/screens/home_screen.dart';

void main() {
  testWidgets('opens checkout from cart', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          ChangeNotifierProvider(create: (_) => FavoriteProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: MaterialApp(
          home: const ProductHomeScreen(),
          routes: {
            '/cart': (context) => const CartScreen(),
            '/checkout': (context) => const CheckoutScreen(),
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('BlueMart Retail'), findsOneWidget);

    final appContext = tester.element(find.byType(MaterialApp));
    appContext.read<CartProvider>().addItem(
      ProductDb.seedProducts.first.toCartItem(),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Keranjang Belanja'), findsOneWidget);

    Navigator.of(
      tester.element(find.text('Keranjang Belanja')),
    ).pushNamed('/checkout');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Konfirmasi Pesanan'), findsOneWidget);
    expect(find.text('Alamat Pengiriman'), findsOneWidget);
  });
}
