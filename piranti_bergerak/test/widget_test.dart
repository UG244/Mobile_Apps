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

    expect(find.text('ShopEase'), findsOneWidget);

    final appContext = tester.element(find.byType(MaterialApp));
    appContext.read<CartProvider>().addItem(
      ProductDb.seedProducts.first.toCartItem(),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Keranjang Belanja'), findsOneWidget);

    await tester.tap(find.textContaining('Checkout'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Pembayaran'), findsOneWidget);
    expect(find.text('Alamat Pengiriman'), findsOneWidget);
  });
}
