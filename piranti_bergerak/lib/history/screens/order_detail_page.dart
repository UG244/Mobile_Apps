import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';
import '../widgets/order_detail_product_item.dart';
import '../widgets/order_payment_summary_card.dart';
import '../widgets/order_shipping_info_card.dart';
import '../widgets/order_status_chip.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderProvider()..loadOrderDetail(orderId),
      child: const _OrderDetailView(),
    );
  }
}

class _OrderDetailView extends StatelessWidget {
  const _OrderDetailView();

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, _) {
        final order = provider.selectedOrder;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            title: const Text('Detail Pesanan'),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1565C0),
          ),
          body: provider.isLoadingDetail
              ? const Center(child: CircularProgressIndicator())
              : order == null
              ? const Center(child: Text('Pesanan tidak ditemukan.'))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth >= 720
                        ? 680.0
                        : double.infinity;

                    return Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Card(
                              elevation: 0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            order.invoice,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        OrderStatusChip(
                                          status: order.status,
                                          color: provider.getStatusColor(
                                            order.status,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      provider.formatDateIndonesia(order.date),
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Card(
                              elevation: 0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.shopping_bag_outlined,
                                          color: Color(0xFF1565C0),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Daftar Produk',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ...provider.selectedDetails.map(
                                      (detail) => OrderDetailProductItem(
                                        detail: detail,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            OrderShippingInfoCard(order: order),
                            const SizedBox(height: 12),
                            OrderPaymentSummaryCard(order: order),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
