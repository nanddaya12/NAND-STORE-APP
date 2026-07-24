import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/store_models.dart';
import '../providers/store_provider.dart';
import '../core/utils/ar_utils.dart';
import 'checkout_screen.dart';
import 'seller/seller_profile_screen.dart';
import 'ar_landing_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedFinish = '';
  String _selectedStorage = '';
  String _selectedSize = '';
  double _addedCost = 0.0;
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    // Default variants selections
    if (widget.product.finishes.isNotEmpty) {
      _selectedFinish = widget.product.finishes[0];
    }
    if (widget.product.storageOptions.isNotEmpty) {
      _selectedStorage = widget.product.storageOptions.keys.first;
      _addedCost = widget.product.storageOptions[_selectedStorage] ?? 0.0;
    }
    if (widget.product.sizes.isNotEmpty) {
      _selectedSize = widget.product.sizes[0];
    }

    // Add to recently viewed items history log
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StoreProvider>(context, listen: false)
          .addToRecentlyViewed(widget.product);
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final relatedProducts = storeProvider.products
        .where((p) => p.category == widget.product.category && p.id != widget.product.id)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Product link copied to clipboard!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              storeProvider.isInWishlist(widget.product.id) ? Icons.favorite : Icons.favorite_border,
              color: storeProvider.isInWishlist(widget.product.id) ? Colors.red : const Color(0xFF000613),
            ),
            onPressed: () {
              storeProvider.toggleWishlist(widget.product.id);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Multiple images carousel with Zoom capability
            _buildImageCarouselSection(),

            // ── View in AR Button ──────────────────────────────────────────
            _buildViewInARButton(context),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge & rating row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.product.badge.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF000613),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.product.badge,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        )
                      else
                        const SizedBox(),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFF7F5700), size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.product.rating}',
                            style: const TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          if (widget.product.reviewsCount > 0)
                            Text(
                              ' (${widget.product.reviewsCount} reviews)',
                              style: const TextStyle(color: Color(0xFF43474E), fontSize: 11),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Name & Stock row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: const TextStyle(color: Color(0xFF000613), fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _buildStockBadge(),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Text(
                    widget.product.description,
                    style: const TextStyle(color: Color(0xFF43474E), height: 1.4, fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // Price & Discount container
                  _buildPriceSection(),
                  const SizedBox(height: 20),

                  // Finish Colors Selector
                  if (widget.product.finishes.isNotEmpty) ...[
                    const Text(
                      'SELECT FINISH',
                      style: TextStyle(color: Color(0xFF43474E), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: widget.product.finishes.map((finish) {
                        final selected = _selectedFinish == finish;
                        Color finishColor = Colors.grey;
                        if (finish == 'Gold') finishColor = const Color(0xFFFFDEAE);
                        if (finish == 'Slate') finishColor = const Color(0xFF334155);
                        if (finish == 'Silver') finishColor = const Color(0xFFE2E8F0);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFinish = finish;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: finishColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected ? const Color(0xFF000613) : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Sizes Selector
                  if (widget.product.sizes.isNotEmpty) ...[
                    const Text(
                      'SELECT SIZE',
                      style: TextStyle(color: Color(0xFF43474E), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: widget.product.sizes.map((size) {
                        final selected = _selectedSize == size;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: ChoiceChip(
                            label: Text(size),
                            selected: selected,
                            selectedColor: const Color(0xFF000613),
                            labelStyle: TextStyle(
                              color: selected ? Colors.white : const Color(0xFF43474E),
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            backgroundColor: const Color(0xFFF6F3F2),
                            onSelected: (val) {
                              setState(() {
                                _selectedSize = size;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Storage capacity selector
                  if (widget.product.storageOptions.isNotEmpty) ...[
                    const Text(
                      'STORAGE CAPACITY',
                      style: TextStyle(color: Color(0xFF43474E), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 10),
                    Grid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.3,
                        crossAxisSpacing: 10,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: widget.product.storageOptions.entries.map((entry) {
                        final storage = entry.key;
                        final cost = entry.value;
                        final selected = _selectedStorage == storage;

                        return OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: selected ? const Color(0x0D000613) : Colors.transparent,
                            side: BorderSide(
                              color: selected ? const Color(0xFF000613) : const Color(0xFFC4C6CF),
                              width: selected ? 2.0 : 1.0,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedStorage = storage;
                              _addedCost = cost;
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                storage,
                                style: const TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                cost == 0.0 ? 'Included' : '+\$${cost.toInt()}',
                                style: TextStyle(color: selected ? const Color(0xFF000613) : const Color(0xFF43474E), fontSize: 9),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 25),
                  ],

                  // Seller / Shop Info Card
                  const Text(
                    'Seller Information',
                    style: TextStyle(color: Color(0xFF000613), fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFC4C6CF), width: 0.5),
                    ),
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 25),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFFFFB62C),
                            backgroundImage: NetworkImage(storeProvider.getSellerProfile(widget.product.sellerId).profileImage),
                            child: storeProvider.getSellerProfile(widget.product.sellerId).profileImage.isEmpty
                                ? const Icon(Icons.store, color: Color(0xFF000613))
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  storeProvider.getSellerProfile(widget.product.sellerId).shopName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF000613)),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Color(0xFFFFB62C), size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${storeProvider.getSellerProfile(widget.product.sellerId).rating} Rating',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF43474E)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SellerProfileScreen(
                                    seller: storeProvider.getSellerProfile(widget.product.sellerId),
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Visit Shop',
                              style: TextStyle(color: Color(0xFF7F5700), fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Specifications Table
                  const Text(
                    'Technical Specifications',
                    style: TextStyle(color: Color(0xFF000613), fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Table(
                    border: TableBorder.all(color: const Color(0xFFC4C6CF), width: 1, borderRadius: BorderRadius.circular(8)),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(3),
                    },
                    children: widget.product.specs.entries.map((entry) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Text(
                              entry.key,
                              style: const TextStyle(color: Color(0xFF43474E), fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Text(
                              entry.value,
                              style: const TextStyle(color: Color(0xFF000613), fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 35),

                  // Related Products Section
                  if (relatedProducts.isNotEmpty) ...[
                    const Text(
                      'Related Products',
                      style: TextStyle(color: Color(0xFF000613), fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: relatedProducts.length,
                        itemBuilder: (context, index) {
                          final rp = relatedProducts[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => ProductDetailScreen(product: rp)),
                              );
                            },
                            child: Container(
                              width: 130,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFC4C6CF)),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF6F3F2),
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                                      ),
                                      width: double.infinity,
                                      child: rp.images.isNotEmpty
                                          ? Image.network(
                                              rp.images.first,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, _e) => Icon(
                                                rp.category == 'Electronics' ? Icons.devices :
                                                rp.category == 'Fashion' ? Icons.checkroom :
                                                rp.category == 'Home' ? Icons.home : Icons.watch,
                                                color: const Color(0xFF000613),
                                                size: 24,
                                              ),
                                            )
                                          : Icon(Icons.devices, color: const Color(0xFF000613), size: 24),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          rp.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF000613)),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '\$${rp.price.toStringAsFixed(2)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF7F5700)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 35),
                  ],

                  // Recently Viewed History Section
                  if (storeProvider.recentlyViewed.length > 1) ...[
                    const Text(
                      'Recently Viewed',
                      style: TextStyle(color: Color(0xFF000613), fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: storeProvider.recentlyViewed.length,
                        itemBuilder: (context, index) {
                          final rv = storeProvider.recentlyViewed[index];
                          // Do not list current viewed product in history row
                          if (rv.id == widget.product.id) return const SizedBox();
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => ProductDetailScreen(product: rv)),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFC4C6CF)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.history, size: 16, color: const Color(0xFF43474E)),
                                  const SizedBox(width: 8),
                                  Text(
                                    rv.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF000613)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 120), // Spacing space for bottom drawer
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFC4C6CF))),
        ),
        child: Row(
          children: [
            // Add To Cart button
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF000613), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  storeProvider.addToCart(
                    widget.product,
                    finish: _selectedFinish,
                    storage: _selectedStorage,
                    size: _selectedSize,
                    addedCost: _addedCost,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.product.name} added to cart!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF000613),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Buy Now button
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000613),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {
                  storeProvider.addToCart(
                    widget.product,
                    finish: _selectedFinish,
                    storage: _selectedStorage,
                    size: _selectedSize,
                    addedCost: _addedCost,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                  );
                },
                child: const Text(
                  'Buy Now',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarouselSection() {
    final images = widget.product.images.isNotEmpty
        ? widget.product.images
        : [
            // Fallback placeholder image
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCLUVQ7shhDLdjT3rjXobnOb5l9R7_8H-uE3D6uFQUH3Lbe5cQLJT6zklK6Qp5yAnrHr1Iwxg3EJfNfZAu1d5kHtDCzgusjxgKIejp-lKVt40I7GzqDROYZeqCl8XgKNvoITDQiAqrrICliWddbJRt8VG1E_s7K_8ZNabDyq-gOMu53E8vH8t2uaS-smyf-iCL5GmahtkFA2FBpNBkPIk5f8hEUVJCi4n10S3NV44BYrD8qs7x-QfNch7KpFa_Y2kdbHxezk1pG-A'
          ];

    return Container(
      height: 300,
      width: double.infinity,
      color: const Color(0xFFF6F3F2),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            itemCount: images.length,
            onPageChanged: (idx) {
              setState(() {
                _currentCarouselIndex = idx;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                clipBehavior: Clip.none,
                minScale: 1.0,
                maxScale: 3.5,
                child: Center(
                  child: Image.network(
                    images[index],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        widget.product.category == 'Electronics' ? Icons.devices : Icons.shopping_bag,
                        size: 90,
                        color: const Color(0xFF000613),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          if (images.length > 1)
            Positioned(
              bottom: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (idx) {
                  final active = _currentCarouselIndex == idx;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFF000613) : const Color(0xFFC4C6CF),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          
          // Video Play button overlay
          if (widget.product.videoUrl != null && widget.product.videoUrl!.isNotEmpty)
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton.extended(
                heroTag: 'video_fab',
                backgroundColor: const Color(0xFF000613),
                foregroundColor: Colors.white,
                elevation: 4,
                onPressed: () => _showMockVideoPlayer(context),
                icon: const Icon(Icons.play_circle_fill, color: Color(0xFFFFB62C)),
                label: const Text('Play Video', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  void _showMockVideoPlayer(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        bool isPlaying = true;
        double progress = 0.0;
        int elapsedSeconds = 0;
        const totalDuration = 30; // 30 seconds mock video
        late Timer videoTimer;

        void startTimer(StateSetter setModalState) {
          videoTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
            setModalState(() {
              if (progress < 1.0) {
                progress += 0.00333; // 30 seconds = 300 ticks of 100ms
                elapsedSeconds = (progress * totalDuration).floor();
              } else {
                progress = 0.0;
                elapsedSeconds = 0;
              }
            });
          });
        }

        return StatefulBuilder(
          builder: (context, setModalState) {
            if (isPlaying && !videoTimer.isActive) {
              startTimer(setModalState);
            }

            String formatTime(int seconds) {
              final mins = (seconds / 60).floor().toString().padLeft(2, '0');
              final secs = (seconds % 60).toString().padLeft(2, '0');
              return '$mins:$secs';
            }

            return Dialog(
              backgroundColor: const Color(0xFF000613), // Deep Indigo
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Video Screen Area
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      image: widget.product.images.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(widget.product.images[0]),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withValues(alpha: 0.6),
                                BlendMode.darken,
                              ),
                            )
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Dynamic Pulse loading ring while playing
                        if (isPlaying)
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 1.0, end: 1.3),
                            duration: const Duration(seconds: 1),
                            builder: (context, val, child) {
                              return Container(
                                width: 70 * val,
                                height: 70 * val,
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFFFB62C).withValues(alpha: 0.4), width: 1.5),
                                  shape: BoxShape.circle,
                                ),
                              );
                            },
                          ),
                        IconButton(
                          iconSize: 64,
                          icon: Icon(
                            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            color: const Color(0xFFFFB62C),
                          ),
                          onPressed: () {
                            setModalState(() {
                              if (isPlaying) {
                                isPlaying = false;
                                videoTimer.cancel();
                              } else {
                                isPlaying = true;
                                startTimer(setModalState);
                              }
                            });
                          },
                        ),
                        Positioned(
                          top: 12,
                          left: 16,
                          child: Text(
                            'Demo: ${widget.product.name}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70),
                            onPressed: () {
                              videoTimer.cancel();
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Media Player Controls
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Progress bar slider
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3.0,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                            activeTrackColor: const Color(0xFFFFB62C),
                            inactiveTrackColor: Colors.white24,
                            thumbColor: const Color(0xFFFFB62C),
                          ),
                          child: Slider(
                            value: progress.clamp(0.0, 1.0),
                            onChanged: (val) {
                              setModalState(() {
                                progress = val;
                                elapsedSeconds = (progress * totalDuration).floor();
                              });
                            },
                          ),
                        ),
                        // Time details
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${formatTime(elapsedSeconds)} / ${formatTime(totalDuration)}',
                                style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: const [
                                  Icon(Icons.volume_up, color: Colors.white70, size: 16),
                                  SizedBox(width: 12),
                                  Icon(Icons.fullscreen, color: Colors.white70, size: 18),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildViewInARButton(BuildContext context) {
    final categoryColor = ARUtils.categoryARColor(widget.product.category);
    final isTryOn = ARUtils.categorySupportsARTryOn(widget.product.category);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => ARLandingScreen(product: widget.product),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                categoryColor.withValues(alpha: 0.9),
                categoryColor.withValues(alpha: 0.6),
                const Color(0xFF0D1520),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: categoryColor.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing icon
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1200),
                tween: Tween(begin: 0.85, end: 1.0),
                builder: (_, v, child) => Transform.scale(scale: v, child: child),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isTryOn ? Icons.face_retouching_natural : Icons.view_in_ar,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isTryOn ? 'Virtual Try-On' : 'View in AR',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    isTryOn ? 'Try before you buy' : 'See it in your space',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Text(
                  'AR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection() {

    final price = widget.product.price + _addedCost;
    final oldPrice = widget.product.oldPrice > 0 ? widget.product.oldPrice + _addedCost : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFC4C6CF)),
          bottom: BorderSide(color: Color(0xFFC4C6CF)),
        ),
      ),
      child: Row(
        children: [
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: const TextStyle(color: Color(0xFF000613), fontSize: 24, fontWeight: FontWeight.w800),
          ),
          if (oldPrice > 0) ...[
            const SizedBox(width: 10),
            Text(
              '\$${oldPrice.toStringAsFixed(2)}',
              style: const TextStyle(color: Color(0xFF43474E), fontSize: 16, decoration: TextDecoration.lineThrough),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDEAE),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '15% OFF',
                style: TextStyle(color: Color(0xFF7F5700), fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStockBadge() {
    final stock = widget.product.stock;
    Color color = Colors.green;
    String status = 'In Stock';
    if (stock <= 0) {
      color = Colors.red;
      status = 'Out of Stock';
    } else if (stock <= 5) {
      color = Colors.orange;
      status = 'Only $stock Left';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Simple Helper class to emulate Grid within column
class Grid extends StatelessWidget {
  final SliverGridDelegate gridDelegate;
  final List<Widget> children;
  final bool shrinkWrap;
  final ScrollPhysics physics;

  const Grid({
    super.key,
    required this.gridDelegate,
    required this.children,
    this.shrinkWrap = false,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  @override
  Widget build(BuildContext context) {
    return GridView(
      gridDelegate: gridDelegate,
      shrinkWrap: shrinkWrap,
      physics: physics,
      children: children,
    );
  }
}
