import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notification_provider.dart';
import '../widgets/empty_notification_widget.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_category_chip.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _NotificationView();
  }
}

class _NotificationView extends StatelessWidget {
  const _NotificationView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final items = provider.filteredNotifications;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Notifikasi'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1565C0),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'read') {
                await provider.markAllAsRead();
              }
              if (value == 'clear') {
                await provider.clearAllNotifications();
              }
              if (value == 'demo') {
                await provider.addDemoNotifications();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'read', child: Text('Tandai semua dibaca')),
              PopupMenuItem(value: 'clear', child: Text('Hapus semua')),
              PopupMenuItem(value: 'demo', child: Text('Tambah contoh promo')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 58,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              scrollDirection: Axis.horizontal,
              itemCount: provider.categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = provider.categories[index];
                return NotificationCategoryChip(
                  label: category,
                  selected: category == provider.selectedType,
                  onTap: () => provider.setFilter(category),
                );
              },
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                ? const EmptyNotificationWidget()
                : RefreshIndicator(
                    onRefresh: provider.loadNotifications,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = constraints.maxWidth >= 720
                            ? 680.0
                            : double.infinity;

                        return Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxWidth),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                final id = item.id ?? 0;
                                final color = provider.getTypeColor(item.type);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Dismissible(
                                    key: ValueKey(id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onDismissed: (_) =>
                                        provider.deleteNotification(id),
                                    child: NotificationCard(
                                      notification: item,
                                      icon: provider.getTypeIcon(item.type),
                                      color: color,
                                      formattedTime: _formatTime(
                                        item.createdAt,
                                      ),
                                      onTap: () => provider.markAsRead(id),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime value) {
    final now = DateTime.now();
    final diff = now.difference(value);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';

    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    return '$day/$month/$year';
  }
}
