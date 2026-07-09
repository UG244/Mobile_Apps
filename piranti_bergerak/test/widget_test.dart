import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:piranti_bergerak/cart/providers/cart_provider.dart';
import 'package:piranti_bergerak/main.dart';
import 'package:piranti_bergerak/product/db/product_db.dart';

void main() {
  testWidgets('opens checkout from cart', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 1));

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
