import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/store_models.dart';
import '../providers/store_provider.dart';
import '../screens/product_detail_screen.dart';
import '../core/utils/ar_utils.dart';
import '../screens/ar_landing_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isWishlistMode;

  const ProductCard({
    super.key,
    required this.product,
    this.isWishlistMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StoreProvider>(context);
    final inWishlist = provider.isInWishlist(product.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFC4C6CF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x03000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upper image/icon slot
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  // Product image with network loading and icon fallback
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: product.images.isNotEmpty
                        ? Image.network(
                            product.images.first,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: const Color(0xFFF6F3F2),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF000613),
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFFF6F3F2),
                                child: Center(
                                  child: Icon(
                                    product.category == 'Electronics' ? Icons.devices :
                                    product.category == 'Fashion' ? Icons.checkroom :
                                    product.category == 'Home' ? Icons.home :
                                    product.category == 'Beauty' ? Icons.content_cut : Icons.watch,
                                    color: const Color(0xFF000613),
                                    size: 36,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: const Color(0xFFF6F3F2),
                            child: Center(
                              child: Icon(
                                product.category == 'Electronics' ? Icons.devices :
                                product.category == 'Fashion' ? Icons.checkroom :
                                product.category == 'Home' ? Icons.home :
                                product.category == 'Beauty' ? Icons.content_cut : Icons.watch,
                                color: const Color(0xFF000613),
                                size: 36,
                              ),
                            ),
                          ),
                  ),
                  // Wishlist heart button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => provider.toggleWishlist(product.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(
                          isWishlistMode ? Icons.favorite : (inWishlist ? Icons.favorite : Icons.favorite_border),
                          color: isWishlistMode ? Colors.red : (inWishlist ? Colors.red : const Color(0xFF43474E)),
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                  // AR badge
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => ARLandingScreen(product: product),
                            transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
                            transitionDuration: const Duration(milliseconds: 400),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: ARUtils.categoryARColor(product.category).withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: ARUtils.categoryARColor(product.category).withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.view_in_ar, color: Colors.white, size: 9),
                            SizedBox(width: 3),
                            Text(
                              'AR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Lower text/actions slot
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFFFB62C), size: 12),
                            const SizedBox(width: 3),
                            Text(
                              '${product.rating}',
                              style: const TextStyle(color: Color(0xFF43474E), fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        if (isWishlistMode)
                          GestureDetector(
                            onTap: () {
                              provider.addToCart(product);
                              provider.toggleWishlist(product.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.name} moved to shopping cart!'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: const Color(0xFF000613),
                                  duration: const Duration(milliseconds: 1500),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF000613),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Move to Cart',
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () {
                              provider.addToCart(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.name} added to cart!'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: const Color(0xFF000613),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF000613),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 14),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
