import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:piranti_bergerak/main.dart';

void main() {
  testWidgets('opens checkout from cart', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('ShopEase'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Keranjang Belanja'), findsOneWidget);

    await tester.tap(find.textContaining('Checkout'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Alamat Pengiriman'), findsOneWidget);
  });
}
