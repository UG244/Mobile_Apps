import 'package:flutter_test/flutter_test.dart';

import 'package:piranti_bergerak/main.dart';

void main() {
  testWidgets('opens checkout from homepage', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('BlueMart Retail'), findsOneWidget);
    expect(find.text('Checkout Sekarang'), findsOneWidget);

    await tester.tap(find.text('Checkout Sekarang'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Alamat Pengiriman'), findsOneWidget);
  });
}
