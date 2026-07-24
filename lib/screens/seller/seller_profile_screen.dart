import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/store_models.dart';
import '../../providers/store_provider.dart';
import '../product_detail_screen.dart';

class SellerProfileScreen extends StatefulWidget {
  final SellerProfile seller;

  const SellerProfileScreen({super.key, required this.seller});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  int _activeTab = 0; // 0 for Products, 1 for Reviews

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final sellerProducts = storeProvider.allProducts
        .where((p) => p.sellerId == widget.seller.id)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      body: CustomScrollView(
        slivers: [
          // Banner Sliver AppBar
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF000613),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Text(
                widget.seller.shopName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  shadows: const [
                    Shadow(color: Colors.black87, blurRadius: 8, offset: Offset(0, 2))
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.seller.bannerImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF000613), Color(0xFF2F486A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      );
                    },
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black54, Colors.transparent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Shop details card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFC4C6CF), width: 0.5)),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: const Color(0xFFFFB62C),
                            backgroundImage: NetworkImage(widget.seller.profileImage),
                            child: widget.seller.profileImage.isEmpty ? const Icon(Icons.store, color: Color(0xFF000613)) : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.seller.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF43474E)),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Color(0xFFFFB62C), size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.seller.rating} rating',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF000613)),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: const Color(0x1A000613), borderRadius: BorderRadius.circular(6)),
                                      child: const Text('VERIFIED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF000613))),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.seller.description,
                        style: const TextStyle(color: Color(0xFF43474E), fontSize: 13, height: 1.4),
                      ),
                      const Divider(height: 30, color: Color(0xFFC4C6CF)),
                      // Contact information
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 16, color: Color(0xFF43474E)),
                          const SizedBox(width: 8),
                          Text(widget.seller.email, style: const TextStyle(fontSize: 12, color: Color(0xFF000613))),
                          const SizedBox(width: 20),
                          const Icon(Icons.phone_android_outlined, size: 16, color: Color(0xFF43474E)),
                          const SizedBox(width: 8),
                          Text(widget.seller.phone, style: const TextStyle(fontSize: 12, color: Color(0xFF000613))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Tab Toggle Selector
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Products'),
                    selected: _activeTab == 0,
                    selectedColor: const Color(0xFF000613),
                    labelStyle: TextStyle(
                      color: _activeTab == 0 ? Colors.white : const Color(0xFF43474E),
                      fontWeight: _activeTab == 0 ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    backgroundColor: const Color(0xFFF6F3F2),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _activeTab = 0;
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Rating & Reviews'),
                    selected: _activeTab == 1,
                    selectedColor: const Color(0xFF000613),
                    labelStyle: TextStyle(
                      color: _activeTab == 1 ? Colors.white : const Color(0xFF43474E),
                      fontWeight: _activeTab == 1 ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    backgroundColor: const Color(0xFFF6F3F2),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _activeTab = 1;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Conditional Sliver view based on selected Tab
          if (_activeTab == 0) ...[
            // Products List title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Posted Products',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF000613)),
                    ),
                    Text(
                      '${sellerProducts.length} items',
                      style: const TextStyle(color: Color(0xFF43474E), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            if (sellerProducts.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48.0),
                  child: Center(
                    child: Text(
                      'No products posted yet by this seller.',
                      style: TextStyle(color: Color(0xFF43474E), fontSize: 13),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.74,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final p = sellerProducts[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFC4C6CF), width: 0.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF6F3F2),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                    image: p.images.isNotEmpty
                                        ? DecorationImage(image: NetworkImage(p.images[0]), fit: BoxFit.cover)
                                        : null,
                                  ),
                                  child: p.images.isEmpty
                                      ? const Center(child: Icon(Icons.devices, color: Color(0xFF000613)))
                                      : null,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF000613)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      p.category,
                                      style: const TextStyle(color: Color(0xFF43474E), fontSize: 10, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '\$${p.price.toStringAsFixed(2)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF7F5700)),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, color: Color(0xFFFFB62C), size: 12),
                                            const SizedBox(width: 2),
                                            Text(
                                              '${p.rating}',
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF000613)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: sellerProducts.length,
                  ),
                ),
              ),
          ] else ...[
            // Rating and Reviews tab view
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Store Rating Breakdown',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF000613)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFC4C6CF), width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                widget.seller.rating.toString(),
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF000613)),
                              ),
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < widget.seller.rating.floor()
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: const Color(0xFFFFB62C),
                                    size: 16,
                                  );
                                }),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.seller.reviews.length} customer reviews',
                                style: const TextStyle(fontSize: 10, color: Color(0xFF43474E)),
                              ),
                            ],
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            child: Column(
                              children: [
                                _buildRatingRow('5 Star', 0.8),
                                const SizedBox(height: 4),
                                _buildRatingRow('4 Star', 0.2),
                                const SizedBox(height: 4),
                                _buildRatingRow('3 Star', 0.0),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Customer Comments',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF000613)),
                    ),
                  ],
                ),
              ),
            ),

            if (widget.seller.reviews.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48.0),
                  child: Center(
                    child: Text(
                      'No customer reviews posted yet for this store.',
                      style: TextStyle(color: Color(0xFF43474E), fontSize: 13),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final r = widget.seller.reviews[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFC4C6CF), width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  r.reviewerName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF000613)),
                                ),
                                Text(
                                  r.date,
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF43474E)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: List.generate(5, (starIdx) {
                                return Icon(
                                  starIdx < r.rating.floor()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: const Color(0xFFFFB62C),
                                  size: 14,
                                );
                              }),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              r.comment,
                              style: const TextStyle(color: Color(0xFF43474E), fontSize: 12, height: 1.4),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: widget.seller.reviews.length,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingRow(String label, double fillPercentage) {
    return Row(
      children: [
        SizedBox(
          width: 36,
          child: Text(
            label,
            style: const TextStyle(fontSize: 9, color: Color(0xFF43474E)),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fillPercentage,
              color: const Color(0xFF000613),
              backgroundColor: const Color(0xFFF6F3F2),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(fillPercentage * 100).toInt()}%',
          style: const TextStyle(fontSize: 9, color: Color(0xFF43474E)),
        ),
      ],
    );
  }
}
