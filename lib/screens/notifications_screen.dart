import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../models/store_models.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final allNotifications = storeProvider.notifications;

    // Filter list
    final filteredNotifications = allNotifications.where((n) {
      if (_activeFilter == 'All') return true;
      return n.type == _activeFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: AppBar(
        title: const Text('Notification Center'),
        actions: [
          if (storeProvider.unreadNotificationsCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all as read',
              onPressed: () {
                storeProvider.markAllNotificationsAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications marked as read.')),
                );
              },
            ),
          if (allNotifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear all',
              onPressed: () {
                storeProvider.clearAllNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification log cleared.')),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Row Chips
          const SizedBox(height: 12),
          _buildFilterChips(),
          const SizedBox(height: 12),

          // Notifications List
          Expanded(
            child: filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final item = filteredNotifications[index];
                      return _buildNotificationItem(context, storeProvider, item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Order', 'Offer', 'System'];
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = _activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter == 'All' ? 'All' : '${filter}s'),
              selected: selected,
              selectedColor: const Color(0xFF000613),
              labelStyle: TextStyle(
                color: selected ? Colors.white : const Color(0xFF43474E),
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
              ),
              backgroundColor: const Color(0xFFF6F3F2),
              onSelected: (val) {
                setState(() {
                  _activeFilter = filter;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.notifications_off_outlined, size: 64, color: Color(0xFFC4C6CF)),
          SizedBox(height: 16),
          Text(
            'No notifications to show',
            style: TextStyle(color: Color(0xFF43474E), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, StoreProvider provider, NotificationItem item) {
    IconData typeIcon = Icons.info_outline;
    Color iconColor = const Color(0xFF000613);

    if (item.type == 'Order') {
      typeIcon = Icons.local_shipping_outlined;
      iconColor = const Color(0xFF7F5700); // Amber
    } else if (item.type == 'Offer') {
      typeIcon = Icons.local_offer_outlined;
      iconColor = Colors.green;
    }

    final date = item.timestamp;
    final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (dir) {
        provider.deleteNotification(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification "${item.title}" deleted.'),
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () {
                // Since this is a simple mock, we show confirmation
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white.withValues(alpha: 0.6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isRead ? const Color(0xFFE2E2E6) : const Color(0xFFC4C6CF),
            width: item.isRead ? 1.0 : 1.2,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F3F2),
              shape: BoxShape.circle,
            ),
            child: Icon(typeIcon, color: iconColor, size: 20),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                    fontSize: 13,
                    color: const Color(0xFF000613),
                  ),
                ),
              ),
              if (!item.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7F5700),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                item.body,
                style: const TextStyle(fontSize: 11, color: Color(0xFF43474E), height: 1.4),
              ),
              const SizedBox(height: 6),
              Text(
                timeStr,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          onTap: () {
            if (!item.isRead) {
              provider.markNotificationAsRead(item.id);
            }
          },
        ),
      ),
    );
  }
}
