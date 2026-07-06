import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';
import '../widgets/empty_order_widget.dart';
import '../widgets/order_history_card.dart';
import 'order_detail_page.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderProvider()..loadOrders(),
      child: const _OrderHistoryView(),
    );
  }
}

class _OrderHistoryView extends StatelessWidget {
  const _OrderHistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1565C0),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.orders.isEmpty) {
            return EmptyOrderWidget(
              onShop: () => Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (_) => false),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refreshOrders,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth >= 720
                    ? 680.0
                    : double.infinity;

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.orders.length,
                      itemBuilder: (context, index) {
                        final order = provider.orders[index];
                        final orderId = order.id ?? 0;
                        final status = provider.getCurrentStatus(order);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: OrderHistoryCard(
                            order: order,
                            totalItems: provider.getTotalItems(orderId),
                            formattedDate: provider.formatDateIndonesia(
                              order.date,
                            ),
                            status: status,
                            statusColor: provider.getStatusColor(status),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      OrderDetailPage(orderId: orderId),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
