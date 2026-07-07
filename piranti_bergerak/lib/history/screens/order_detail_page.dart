import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../providers/order_provider.dart';
import '../widgets/order_detail_product_item.dart';
import '../widgets/order_payment_summary_card.dart';
import '../widgets/order_shipping_info_card.dart';
import '../widgets/order_status_chip.dart';
import '../widgets/order_tracking_card.dart';

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
        final status = order == null ? '' : provider.getCurrentStatus(order);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Detail Pesanan'),
            centerTitle: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: provider.isLoadingDetail
              ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
              : order == null
              ? const Center(child: Text('Pesanan tidak ditemukan.', style: TextStyle(color: AppColors.textSecondary)))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth >= 720 ? 680.0 : double.infinity;

                    return Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.border),
                                boxShadow: AppColors.cardShadow,
                              ),
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
                                            fontSize: 16.5,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      OrderStatusChip(
                                        status: status,
                                        color: provider.getStatusColor(status),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    provider.formatDateIndonesia(order.date),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.border),
                                boxShadow: AppColors.cardShadow,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.shopping_bag_rounded,
                                        color: AppColors.accent,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Daftar Produk yang Dibeli',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Divider(height: 1, color: AppColors.divider),
                                  ),
                                  ...provider.selectedDetails.map(
                                    (detail) => OrderDetailProductItem(detail: detail),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            OrderTrackingCard(
                              summary: provider.getTrackingSummary(order),
                              estimatedArrival: provider.getEstimatedArrival(order),
                              steps: provider.getTrackingSteps(order),
                            ),
                            const SizedBox(height: 14),
                            OrderShippingInfoCard(order: order),
                            const SizedBox(height: 14),
                            OrderPaymentSummaryCard(order: order),
                            const SizedBox(height: 24),
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
