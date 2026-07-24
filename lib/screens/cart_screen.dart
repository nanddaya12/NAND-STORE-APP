import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../models/store_models.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCouponCode(StoreProvider provider) {
    if (_couponController.text.isNotEmpty) {
      final success = provider.applyCoupon(_couponController.text);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coupon applied: 20% discount!'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _couponController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid coupon code! Try "NAND20"'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final cartItems = storeProvider.cart;

    // Filter wishlist items for "Saved for Later" shelf
    final savedItems = dummyProducts.where((p) => storeProvider.isInWishlist(p.id)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: cartItems.isEmpty && savedItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Color(0xFFC4C6CF)),
                  SizedBox(height: 15),
                  Text('Your cart is empty', style: TextStyle(color: Color(0xFF43474E), fontSize: 16)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (cartItems.isNotEmpty) ...[
                        const Text(
                          'Items in Cart',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF000613)),
                        ),
                        const SizedBox(height: 12),
                        // List of items wrapped in Dismissible swipe to delete
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            return _buildCartItemCard(context, storeProvider, item);
                          },
                        ),
                      ] else ...[
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text('Active cart is empty.', style: TextStyle(color: Color(0xFF43474E), fontSize: 13)),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Saved For Later Shelf
                      if (savedItems.isNotEmpty) ...[
                        const Text(
                          'Saved for Later',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF000613)),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 130,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: savedItems.length,
                            itemBuilder: (context, index) {
                              final p = savedItems[index];
                              return _buildSavedItemCard(storeProvider, p);
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Financial Checkout Summary panel
                if (cartItems.isNotEmpty) _buildSummaryPanel(storeProvider),
              ],
            ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, StoreProvider storeProvider, CartItem item) {
    String itemDetails = '';
    if (item.selectedFinish.isNotEmpty) {
      itemDetails += item.selectedFinish;
    }
    if (item.selectedStorage.isNotEmpty) {
      itemDetails += itemDetails.isEmpty ? item.selectedStorage : ' / ${item.selectedStorage}';
    }
    if (item.selectedSize.isNotEmpty) {
      itemDetails += itemDetails.isEmpty ? item.selectedSize : ' / ${item.selectedSize}';
    }

    return Dismissible(
      key: ValueKey('cart_key_${item.product.id}_${item.selectedFinish}_${item.selectedStorage}_${item.selectedSize}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        // Save copy of properties for UNDO
        final product = item.product;
        final finish = item.selectedFinish;
        final storage = item.selectedStorage;
        final size = item.selectedSize;
        final qty = item.quantity;
        final cost = item.addedCost;

        storeProvider.removeFromCart(
          product.id,
          finish: finish,
          storage: storage,
          size: size,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} removed from cart'),
            action: SnackBarAction(
              label: 'UNDO',
              textColor: const Color(0xFFFFB62C),
              onPressed: () {
                for (int i = 0; i < qty; i++) {
                  storeProvider.addToCart(
                    product,
                    finish: finish,
                    storage: storage,
                    size: size,
                    addedCost: cost,
                  );
                }
              },
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFC4C6CF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x03000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 70,
                height: 70,
                child: item.product.images.isNotEmpty
                    ? Image.network(
                        item.product.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, _e) => Container(
                          color: const Color(0xFFF6F3F2),
                          child: Icon(
                            item.product.category == 'Electronics' ? Icons.devices :
                            item.product.category == 'Fashion' ? Icons.checkroom :
                            item.product.category == 'Home' ? Icons.home :
                            item.product.category == 'Beauty' ? Icons.content_cut : Icons.watch,
                            color: const Color(0xFF000613),
                            size: 26,
                          ),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFF6F3F2),
                        child: Icon(
                          item.product.category == 'Electronics' ? Icons.devices :
                          item.product.category == 'Fashion' ? Icons.checkroom :
                          item.product.category == 'Home' ? Icons.home :
                          item.product.category == 'Beauty' ? Icons.content_cut : Icons.watch,
                          color: const Color(0xFF000613),
                          size: 26,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  if (itemDetails.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      itemDetails,
                      style: const TextStyle(color: Color(0xFF43474E), fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${item.singleItemPrice.toStringAsFixed(2)}',
                        style: const TextStyle(color: Color(0xFF7F5700), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const Spacer(),
                      // Save for Later text button
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(40, 20),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          // Toggle wishlist (marks as saved)
                          if (!storeProvider.isInWishlist(item.product.id)) {
                            storeProvider.toggleWishlist(item.product.id);
                          }
                          // Remove from cart
                          storeProvider.removeFromCart(
                            item.product.id,
                            finish: item.selectedFinish,
                            storage: item.selectedStorage,
                            size: item.selectedSize,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.product.name} saved for later!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text('Save for later', style: TextStyle(fontSize: 10, color: Color(0xFF000613))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF43474E), size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        storeProvider.updateQuantity(
                          item.product.id,
                          item.quantity - 1,
                          finish: item.selectedFinish,
                          storage: item.selectedStorage,
                          size: item.selectedSize,
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Color(0xFF43474E), size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        storeProvider.updateQuantity(
                          item.product.id,
                          item.quantity + 1,
                          finish: item.selectedFinish,
                          storage: item.selectedStorage,
                          size: item.selectedSize,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedItemCard(StoreProvider provider, Product p) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC4C6CF)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 50,
              height: 50,
              child: p.images.isNotEmpty
                  ? Image.network(
                      p.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, _e) => Container(
                        color: const Color(0xFFF6F3F2),
                        child: Icon(
                          p.category == 'Electronics' ? Icons.devices :
                          p.category == 'Fashion' ? Icons.checkroom : Icons.shopping_bag,
                          color: const Color(0xFF000613),
                          size: 20,
                        ),
                      ),
                    )
                  : Container(
                      color: const Color(0xFFF6F3F2),
                      child: Icon(
                        p.category == 'Electronics' ? Icons.devices :
                        p.category == 'Fashion' ? Icons.checkroom : Icons.shopping_bag,
                        color: const Color(0xFF000613),
                        size: 20,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF000613)),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${p.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Color(0xFF7F5700), fontWeight: FontWeight.bold, fontSize: 10),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    // Move to cart
                    provider.addToCart(p);
                    // Remove from wishlist
                    provider.toggleWishlist(p.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF000613),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Move to Cart', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPanel(StoreProvider storeProvider) {
    final shippingCost = storeProvider.estimatedShipping;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(color: Color(0x05000000), blurRadius: 12, offset: Offset(0, -4)),
        ],
        border: Border(top: BorderSide(color: Color(0xFFC4C6CF))),
      ),
      child: Column(
        children: [
          // Promo Code input bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  style: const TextStyle(color: Color(0xFF1C1B1B), fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Enter Coupon (NAND20)',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    filled: true,
                    fillColor: const Color(0xFFF6F3F2),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFC4C6CF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF000613)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000613),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _applyCouponCode(storeProvider),
                child: const Text('Apply', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          if (storeProvider.appliedCoupon.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Coupon Applied: ${storeProvider.appliedCoupon} (-20%)', style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: storeProvider.removeCoupon,
                  child: const Text('Remove', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
          const Divider(color: Color(0xFFC4C6CF), height: 24),

          // Calculations Details Lists
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: Color(0xFF43474E), fontSize: 12)),
              Text('\$${storeProvider.cartSubtotal.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          if (storeProvider.discountAmount > 0) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Promo Discount', style: TextStyle(color: Color(0xFF10B981), fontSize: 12)),
                Text('-\$${storeProvider.discountAmount.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ],
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estimated Shipping', style: TextStyle(color: Color(0xFF43474E), fontSize: 12)),
              Text(
                shippingCost == 0.0 ? 'FREE' : '\$${shippingCost.toStringAsFixed(2)}',
                style: TextStyle(
                  color: shippingCost == 0.0 ? const Color(0xFF10B981) : const Color(0xFF000613),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Taxes (8%)', style: TextStyle(color: Color(0xFF43474E), fontSize: 12)),
              Text('\$${storeProvider.cartTax.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estimated Total', style: TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.bold, fontSize: 14)),
              Text(
                '\$${storeProvider.cartTotal.toStringAsFixed(2)}',
                style: const TextStyle(color: Color(0xFF7F5700), fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Checkout navigation trigger
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000613),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                );
              },
              child: const Text('Proceed to Checkout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
