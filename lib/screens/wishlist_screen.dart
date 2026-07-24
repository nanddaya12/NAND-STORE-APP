import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../features/catalog/domain/entities/product.dart';
import '../widgets/product_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final wishlistIds = storeProvider.wishlist;

    // Filter products that are in user wishlist (from live provider, not static list)
    final wishlistedProducts = storeProvider.allProducts.where((p) => wishlistIds.contains(p.id)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: AppBar(
        title: const Text('My Wishlist'),
      ),
      body: wishlistedProducts.isEmpty
          ? _buildEmptyState(context)
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: wishlistedProducts.length,
              itemBuilder: (context, index) {
                final product = wishlistedProducts[index];
                return _buildWishlistItemCard(context, storeProvider, product);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF6F3F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_outline,
                size: 64,
                color: Color(0xFFC4C6CF),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Wishlist is Empty',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF000613)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explore products and add your favorites to custom catalogs sheets.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF43474E), fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 32),
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
                  // Navigate back to main catalog
                  Navigator.pop(context);
                },
                child: const Text('Explore Products', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistItemCard(BuildContext context, StoreProvider provider, Product product) {
    return ProductCard(product: product, isWishlistMode: true);
  }
}
