import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final allOrders = storeProvider.orders;

    // Filter into Current and Past orders
    final currentOrders = allOrders.where((o) => o['status'] == 'Processing' || o['status'] == 'Shipped').toList();
    final pastOrders = allOrders.where((o) => o['status'] == 'Delivered' || o['status'] == 'Cancelled' || o['status'] == 'Returned').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCF9F8),
        appBar: AppBar(
          title: const Text('My Orders'),
          bottom: const TabBar(
            labelColor: Color(0xFF000613),
            unselectedLabelColor: Color(0xFF43474E),
            indicatorColor: Color(0xFF000613),
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: 'Active Orders'),
              Tab(text: 'Past Orders'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrdersList(context, currentOrders, 'No active orders placed.'),
            _buildOrdersList(context, pastOrders, 'No past orders recorded.'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, List<Map<String, dynamic>> list, String emptyMsg) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: Color(0xFFC4C6CF)),
            const SizedBox(height: 16),
            Text(emptyMsg, style: const TextStyle(color: Color(0xFF43474E), fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final order = list[index];
        final date = order['date'] as DateTime;
        final items = order['items'] as List<dynamic>;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFC4C6CF)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order['id'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF000613)),
                ),
                _buildStatusTag(order['status'] as String),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Placed on ${date.day}/${date.month}/${date.year} • ${items.length} items',
                  style: const TextStyle(color: Color(0xFF43474E), fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Paid: \$${(order['total'] as double).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF000613)),
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF43474E)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(orderId: order['id'] as String),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusTag(String status) {
    Color bg = const Color(0x1A7F5700);
    Color fg = const Color(0xFF7F5700);

    if (status == 'Delivered') {
      bg = const Color(0x1A2E7D32);
      fg = const Color(0xFF2E7D32);
    } else if (status == 'Cancelled') {
      bg = const Color(0x1AC62828);
      fg = const Color(0xFFC62828);
    } else if (status == 'Returned') {
      bg = const Color(0x1A37474F);
      fg = const Color(0xFF37474F);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}

// Order detail screen
class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  void _simulateDownload() {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    // Animate progress counting up to 100% in 1.5 seconds
    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_downloadProgress < 1.0) {
          _downloadProgress += 0.1;
        } else {
          _isDownloading = false;
          timer.cancel();
          // Pop alert success dialog
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Download Complete'),
              content: const Text('Invoice PDF has been successfully stored to your local downloads folder.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK', style: TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }
      });
    });
  }

  void _showReviewDialog(BuildContext context, String productName) {
    int rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: Text('Review: $productName', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Rate this product:', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIdx = index + 1;
                    return GestureDetector(
                      onTap: () {
                        setModalState(() {
                          rating = starIdx;
                        });
                      },
                      child: Icon(
                        starIdx <= rating ? Icons.star : Icons.star_border,
                        color: const Color(0xFFFFB62C),
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Share your experience with this item...',
                    hintStyle: const TextStyle(fontSize: 11),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thank you! Your product review has been submitted.')),
                  );
                },
                child: const Text('Submit Review', style: TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final order = storeProvider.orders.firstWhere((o) => o['id'] == widget.orderId);
    final items = order['items'] as List<dynamic>;
    final status = order['status'] as String;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Details ID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order['id'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          'Placed on ${(order['date'] as DateTime).day}/${(order['date'] as DateTime).month}/${(order['date'] as DateTime).year}',
                          style: const TextStyle(color: Color(0xFF43474E), fontSize: 12),
                        ),
                      ],
                    ),
                    _buildStatusTag(status),
                  ],
                ),
                const Divider(color: Color(0xFFC4C6CF), height: 32),

                // Tracking Timeline stepper
                const Text('Tracking Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 16),
                _buildTimeline(status),
                const Divider(color: Color(0xFFC4C6CF), height: 32),

                // Invoice List breakdown
                const Text('Invoice Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFC4C6CF)),
                  ),
                  child: Column(
                    children: [
                      ...items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item['quantity']}x ${item['name']}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF1C1B1B)),
                                ),
                              ),
                              Text(
                                '\$${((item['price'] as double) * (item['quantity'] as int)).toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }),
                      const Divider(color: Color(0xFFC4C6CF), height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount Paid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(
                            '\$${(order['total'] as double).toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF000613)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFFC4C6CF), height: 32),

                // Shipping details
                const Text('Delivery Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Text('Address: ${order['shippingAddress']}', style: const TextStyle(fontSize: 12, height: 1.4)),
                const SizedBox(height: 4),
                Text('Method: ${order['deliveryMethod']}', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Text('Payment: ${order['paymentMethod']}', style: const TextStyle(fontSize: 12)),
                if ((order['orderNotes'] as String).isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Notes: ${order['orderNotes']}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                ],
                const SizedBox(height: 32),

                // Contextual buttons triggers
                if (status == 'Processing') ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        storeProvider.updateOrderStatus(widget.orderId, 'Cancelled');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Order has been cancelled. Refund initialized.')),
                        );
                      },
                      child: const Text('Cancel Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                if (status == 'Delivered') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF000613)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            storeProvider.updateOrderStatus(widget.orderId, 'Returned');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Return request created. Logistics partner notified.')),
                            );
                          },
                          child: const Text('Return Order', style: TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF000613),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => _showReviewDialog(context, items[0]['name'] as String),
                          child: const Text('Write Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Download Invoice Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF000613)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _simulateDownload,
                    icon: const Icon(Icons.download, color: Color(0xFF000613)),
                    label: const Text('Download Invoice Receipt', style: TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),

          // Download Overlay Indicator
          if (_isDownloading)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: Center(
                child: Card(
                  color: Colors.white,
                  margin: const EdgeInsets.all(32),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Color(0xFF000613)),
                        const SizedBox(height: 16),
                        Text(
                          'Downloading Receipt: ${(_downloadProgress * 100).toInt()}%',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        const Text('Please wait, generating invoice PDF...', style: TextStyle(color: Colors.black54, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color bg = const Color(0x1A7F5700);
    Color fg = const Color(0xFF7F5700);

    if (status == 'Delivered') {
      bg = const Color(0x1A2E7D32);
      fg = const Color(0xFF2E7D32);
    } else if (status == 'Cancelled') {
      bg = const Color(0x1AC62828);
      fg = const Color(0xFFC62828);
    } else if (status == 'Returned') {
      bg = const Color(0x1A37474F);
      fg = const Color(0xFF37474F);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildTimeline(String status) {
    // Determine active stage checkpoints
    int activeStage = 1; // 1 = Placed
    if (status == 'Processing') activeStage = 2;
    if (status == 'Shipped') activeStage = 3;
    if (status == 'Delivered') activeStage = 5;

    final stages = [
      {'title': 'Order Placed', 'subtitle': 'Verified successfully'},
      {'title': 'Processing', 'subtitle': 'Preparing packaging'},
      {'title': 'Shipped', 'subtitle': 'Dispatched priority hub'},
      {'title': 'Out for Delivery', 'subtitle': 'Logistics partner assigned'},
      {'title': 'Delivered', 'subtitle': 'Handed over directly'},
    ];

    if (status == 'Cancelled') {
      return Row(
        children: const [
          Icon(Icons.cancel, color: Colors.redAccent, size: 20),
          SizedBox(width: 12),
          Text(
            'Order Cancelled (Refund details sent to email)',
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      );
    }

    if (status == 'Returned') {
      return Row(
        children: const [
          Icon(Icons.assignment_return, color: Color(0xFF37474F), size: 20),
          SizedBox(width: 12),
          Text(
            'Order Returned (Package pickup scheduled)',
            style: TextStyle(color: Color(0xFF37474F), fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      );
    }

    return Column(
      children: List.generate(stages.length, (index) {
        final stageIdx = index + 1;
        final isCompleted = stageIdx <= activeStage;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isCompleted ? const Color(0xFF000613) : const Color(0xFFC4C6CF),
                  size: 18,
                ),
                if (index < stages.length - 1)
                  Container(
                    width: 2,
                    height: 35,
                    color: stageIdx < activeStage ? const Color(0xFF000613) : const Color(0xFFC4C6CF),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stages[index]['title']!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isCompleted ? const Color(0xFF000613) : const Color(0xFFC4C6CF),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stages[index]['subtitle']!,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF43474E)),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
