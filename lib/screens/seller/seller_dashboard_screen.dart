import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/store_provider.dart';
import '../../models/store_models.dart';
import '../auth/role_selection_screen.dart';
import '../../widgets/media_upload_dialog.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  int _currentTab = 0;
  String _shopName = 'NAND Premium Outlets';
  String _shopDesc = 'Official premium seller for NAND Store catalog lines.';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final storeProvider = Provider.of<StoreProvider>(context);

    // Route Guard
    if (!authProvider.isLoggedIn || authProvider.userRole != 'seller') {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('This portal is reserved for Seller profiles only.'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  authProvider.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      );
    }

    final tabs = [
      _buildOverviewTab(storeProvider),
      _buildProductsTab(storeProvider),
      _buildOrdersTab(storeProvider),
      _buildCouponsTab(storeProvider),
      _buildSettingsTab(authProvider),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        backgroundColor: const Color(0xFF000613),
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _handleLogout(authProvider),
          ),
        ],
      ),
      body: tabs[_currentTab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (idx) {
          setState(() {
            _currentTab = idx;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF7F5700),
        unselectedItemColor: const Color(0xFF43474E),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer_outlined),
            activeIcon: Icon(Icons.local_offer),
            label: 'Coupons',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _handleLogout(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of the Seller Portal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                (route) => false,
              );
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ==================== 1. OVERVIEW TAB ====================
  Widget _buildOverviewTab(StoreProvider provider) {
    final productsCount = provider.allProducts.length;
    final ordersCount = provider.orders.length;
    final double revenue = provider.orders
        .where((o) => o['status'] != 'Cancelled')
        .fold(0.0, (sum, o) => sum + (o['total'] as double));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Store Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF000613)),
          ),
          const SizedBox(height: 16),
          
          // Stats grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: [
              _buildStatCard('Total Revenue', '\$${revenue.toStringAsFixed(2)}', Icons.monetization_on, Colors.green),
              _buildStatCard('Total Orders', '$ordersCount', Icons.receipt_long, Colors.blue),
              _buildStatCard('Active Products', '$productsCount', Icons.inventory, const Color(0xFF7F5700)),
              _buildStatCard('Store Rating', '4.8 ★', Icons.star, Colors.orange),
            ],
          ),
          const SizedBox(height: 24),

          // Mini sales breakdown list
          const Text(
            'Recent Orders Logs',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF000613)),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.orders.length,
            itemBuilder: (context, idx) {
              final order = provider.orders[idx];
              final date = order['date'] as DateTime;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFC4C6CF)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['id'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF000613)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}/${date.month}/${date.year} • \$${(order['total'] as double).toStringAsFixed(2)}',
                          style: const TextStyle(color: Color(0xFF43474E), fontSize: 12),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order['status'] as String).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order['status'] as String,
                        style: TextStyle(
                          color: _getStatusColor(order['status'] as String),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String val, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC4C6CF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 24),
              const Icon(Icons.trending_up, color: Colors.green, size: 16),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                val,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF000613)),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF43474E)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== 2. PRODUCTS TAB (CRUD) ====================
  Widget _buildProductsTab(StoreProvider provider) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7F5700),
        foregroundColor: Colors.white,
        onPressed: () => _showProductFormDialog(provider),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.allProducts.length,
        itemBuilder: (context, idx) {
          final product = provider.allProducts[idx];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC4C6CF)),
            ),
            child: Row(
              children: [
                // Product icon / image placeholder
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F3F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.shopping_bag_outlined, color: Color(0xFF7F5700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF000613), fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Category: ${product.category} • Stock: ${product.stock}',
                        style: const TextStyle(color: Color(0xFF43474E), fontSize: 11),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7F5700), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Edit and Delete controls
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                  onPressed: () => _showProductFormDialog(provider, product: product),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete Product'),
                        content: Text('Are you sure you want to delete ${product.name}?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              provider.deleteProduct(product.id);
                              Navigator.pop(context);
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showProductFormDialog(StoreProvider provider, {Product? product}) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final descCtrl = TextEditingController(text: product?.description ?? '');
    final priceCtrl = TextEditingController(text: product?.price.toString() ?? '');
    final stockCtrl = TextEditingController(text: product?.stock.toString() ?? '15');
    final imageCtrl = TextEditingController(text: product?.images.isNotEmpty == true ? product!.images[0] : '');
    final videoCtrl = TextEditingController(text: product?.videoUrl ?? '');
    String selectedCategory = product?.category ?? 'Electronics';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          scrollable: true,
          title: Text(product == null ? 'Add Product' : 'Edit Product'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Price (\$)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => v == null || double.tryParse(v) == null ? 'Enter valid price' : null,
                ),
                TextFormField(
                  controller: stockCtrl,
                  decoration: const InputDecoration(labelText: 'Stock Units'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || int.tryParse(v) == null ? 'Enter valid stock' : null,
                ),
                TextFormField(
                  controller: imageCtrl,
                  decoration: InputDecoration(
                    labelText: 'Image URL',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF7F5700)),
                      tooltip: 'Upload Image',
                      onPressed: () async {
                        final result = await showDialog<String>(
                          context: context,
                          builder: (_) => const MediaUploadDialog(mediaType: 'image'),
                        );
                        if (result != null) {
                          imageCtrl.text = result;
                        }
                      },
                    ),
                  ),
                ),
                TextFormField(
                  controller: videoCtrl,
                  decoration: InputDecoration(
                    labelText: 'Video URL (Optional)',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.video_call_outlined, color: Color(0xFF7F5700)),
                      tooltip: 'Upload Video',
                      onPressed: () async {
                        final result = await showDialog<String>(
                          context: context,
                          builder: (_) => const MediaUploadDialog(mediaType: 'video'),
                        );
                        if (result != null) {
                          videoCtrl.text = result;
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: ['Electronics', 'Fashion', 'Home', 'Accessories']
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) selectedCategory = val;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final double price = double.parse(priceCtrl.text);
                  final int stock = int.parse(stockCtrl.text);
                  final String imgUrl = imageCtrl.text.trim().isNotEmpty
                      ? imageCtrl.text.trim()
                      : 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=600&auto=format&fit=crop';
                  final String? vidUrl = videoCtrl.text.trim().isNotEmpty
                      ? videoCtrl.text.trim()
                      : null;

                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final sellerId = 's_${authProvider.currentUserEmail?.split('@')[0] ?? '1'}';

                  if (product == null) {
                    // Create new
                    final newProduct = Product(
                      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                      name: nameCtrl.text,
                      description: descCtrl.text,
                      price: price,
                      stock: stock,
                      category: selectedCategory,
                      rating: 5.0,
                      icon: 'shopping_bag',
                      specs: const {},
                      images: [imgUrl],
                      videoUrl: vidUrl,
                      sellerId: sellerId,
                    );
                    provider.addProduct(newProduct);
                  } else {
                    // Update existing
                    final updatedProduct = Product(
                      id: product.id,
                      name: nameCtrl.text,
                      description: descCtrl.text,
                      price: price,
                      stock: stock,
                      category: selectedCategory,
                      rating: product.rating,
                      icon: product.icon,
                      specs: product.specs,
                      images: [imgUrl],
                      videoUrl: vidUrl,
                      finishes: product.finishes,
                      storageOptions: product.storageOptions,
                      sizes: product.sizes,
                      badge: product.badge,
                      reviewsCount: product.reviewsCount,
                      oldPrice: product.oldPrice,
                      sellerId: product.sellerId,
                    );
                    provider.updateProduct(updatedProduct);
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(product == null ? 'Add' : 'Save', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7F5700))),
            ),
          ],
        );
      },
    );
  }

  // ==================== 3. ORDERS TAB (Logistics management) ====================
  Widget _buildOrdersTab(StoreProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.orders.length,
      itemBuilder: (context, idx) {
        final order = provider.orders[idx];
        final items = order['items'] as List<dynamic>;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFC4C6CF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order['id'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF000613), fontSize: 14),
                  ),
                  _buildStatusDropdown(provider, order),
                ],
              ),
              const Divider(height: 24),
              Text(
                'Customer Delivery Information:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey[700]),
              ),
              const SizedBox(height: 4),
              Text(
                order['shippingAddress'] as String,
                style: const TextStyle(fontSize: 12, color: Color(0xFF43474E)),
              ),
              const SizedBox(height: 12),
              Text(
                'Order Content:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey[700]),
              ),
              const SizedBox(height: 4),
              Column(
                children: items.map((it) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${it['name']} x ${it['quantity']}', style: const TextStyle(fontSize: 12)),
                        Text('\$${((it['price'] as double) * (it['quantity'] as int)).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Customer Paid:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(
                    '\$${(order['total'] as double).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF7F5700)),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusDropdown(StoreProvider provider, Map<String, dynamic> order) {
    String currentStatus = order['status'] as String;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 32,
      decoration: BoxDecoration(
        color: _getStatusColor(currentStatus).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentStatus,
          style: TextStyle(color: _getStatusColor(currentStatus), fontWeight: FontWeight.bold, fontSize: 11),
          items: ['Processing', 'Shipped', 'Delivered', 'Cancelled']
              .map((st) => DropdownMenuItem(value: st, child: Text(st)))
              .toList(),
          onChanged: (val) {
            if (val != null) {
              provider.updateOrderStatus(order['id'] as String, val);
            }
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Processing':
        return Colors.blue;
      case 'Shipped':
        return Colors.orange;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
      default:
        return Colors.red;
    }
  }

  // ==================== 4. COUPONS TAB ====================
  Widget _buildCouponsTab(StoreProvider provider) {
    final formKey = GlobalKey<FormState>();
    final codeCtrl = TextEditingController();
    final rateCtrl = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Promo Coupon',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF000613)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFC4C6CF)),
            ),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: codeCtrl,
                    decoration: const InputDecoration(labelText: 'Coupon Code (e.g. SAVE30)'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter code' : null,
                  ),
                  TextFormField(
                    controller: rateCtrl,
                    decoration: const InputDecoration(labelText: 'Discount Percentage (e.g. 30 for 30%)'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = v == null ? null : double.tryParse(v);
                      if (n == null || n <= 0 || n > 100) return 'Enter rate between 1 and 100';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7F5700),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final double discFraction = double.parse(rateCtrl.text) / 100.0;
                          provider.addCoupon(codeCtrl.text.trim().toUpperCase(), discFraction);
                          codeCtrl.clear();
                          rateCtrl.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Promo coupon added successfully!')),
                          );
                        }
                      },
                      child: const Text('Add Coupon', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Active Promotional Coupons',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF000613)),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.coupons.length,
            itemBuilder: (context, idx) {
              final key = provider.coupons.keys.elementAt(idx);
              final val = provider.coupons[key]!;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFC4C6CF)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_offer, color: Color(0xFF7F5700), size: 18),
                        const SizedBox(width: 10),
                        Text(
                          key,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF000613)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${((val * 100).round())}% Off)',
                          style: const TextStyle(color: Color(0xFF43474E), fontSize: 13),
                        )
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () => provider.removeCouponFromList(key),
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  // ==================== 5. SETTINGS TAB ====================
  Widget _buildSettingsTab(AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shop Profile Info',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF000613)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFC4C6CF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _shopName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF000613)),
                ),
                const SizedBox(height: 6),
                Text(
                  _shopDesc,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF43474E), height: 1.4),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Registered Seller ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF000613))),
                        const SizedBox(height: 2),
                        Text(authProvider.currentUserEmail ?? 'seller@nand.com', style: const TextStyle(fontSize: 11, color: Color(0xFF43474E))),
                      ],
                    ),
                    const Icon(Icons.verified_user, color: Colors.blue, size: 20),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Shop Management Settings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF000613)),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFC4C6CF)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: Color(0xFF7F5700)),
                  title: const Text('Edit Shop Details', style: TextStyle(fontSize: 13)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    final ctrlName = TextEditingController(text: _shopName);
                    final ctrlDesc = TextEditingController(text: _shopDesc);
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Edit Shop Info'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(controller: ctrlName, decoration: const InputDecoration(labelText: 'Shop Name')),
                            TextField(controller: ctrlDesc, decoration: const InputDecoration(labelText: 'Description')),
                          ],
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _shopName = ctrlName.text;
                                _shopDesc = ctrlDesc.text;
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7F5700))),
                          )
                        ],
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_active_outlined, color: Color(0xFF7F5700)),
                  title: const Text('Sales Notifications', style: TextStyle(fontSize: 13)),
                  trailing: Switch(
                    value: true,
                    activeThumbColor: const Color(0xFF7F5700),
                    onChanged: (val) {},
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.power_settings_new, color: Colors.redAccent),
                  title: const Text('Log Out Shop Session', style: TextStyle(fontSize: 13, color: Colors.redAccent)),
                  onTap: () => _handleLogout(authProvider),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
