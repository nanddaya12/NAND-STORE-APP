import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../providers/auth_provider.dart';
import '../models/store_models.dart';
import 'product_detail_screen.dart';
import 'categories_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'wishlist_screen.dart';
import 'notifications_screen.dart';
import 'auth/role_selection_screen.dart';
import '../widgets/product_card.dart';
import '../widgets/app_navigation_drawer.dart';
import '../widgets/voice_search_dialog.dart';
import '../core/utils/ar_utils.dart';
import 'ar_landing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _isFetchingMore = false;

  // Pagination lists
  final List<Product> _paginatedProducts = [];
  int _page = 1;
  late ScrollController _scrollController;

  // Countdown timer for Flash Sale
  late Timer _flashSaleTimer;
  Duration _flashSaleTimeLeft = const Duration(hours: 4, minutes: 12, seconds: 30);

  final List<String> _categories = ['All', 'Electronics', 'Fashion', 'Home', 'Accessories'];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _startFlashSaleTimer();
    _loadInitialProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _flashSaleTimer.cancel();
    super.dispose();
  }

  void _startFlashSaleTimer() {
    _flashSaleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_flashSaleTimeLeft.inSeconds > 0) {
          _flashSaleTimeLeft = _flashSaleTimeLeft - const Duration(seconds: 1);
        } else {
          // Reset timer back to mock 4 hours
          _flashSaleTimeLeft = const Duration(hours: 4, minutes: 0, seconds: 0);
        }
      });
    });
  }

  void _loadInitialProducts() {
    _paginatedProducts.clear();
    final allProducts = Provider.of<StoreProvider>(context, listen: false).allProducts;
    _paginatedProducts.addAll(allProducts);
    _page = 1;
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _loadInitialProducts();
      _isLoading = false;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isFetchingMore || _isLoading) return;
    setState(() {
      _isFetchingMore = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final allProducts = Provider.of<StoreProvider>(context, listen: false).allProducts;

    setState(() {
      _page++;
      // Simulate pagination by duplicating items with new index names
      for (var p in allProducts) {
        _paginatedProducts.add(Product(
          id: '${p.id}_page$_page',
          name: '${p.name} (Series $_page)',
          description: p.description,
          price: p.price,
          oldPrice: p.oldPrice,
          rating: p.rating,
          reviewsCount: p.reviewsCount,
          category: p.category,
          icon: p.icon,
          badge: p.badge,
          specs: p.specs,
          finishes: p.finishes,
          storageOptions: p.storageOptions,
          images: p.images,
          videoUrl: p.videoUrl,
        ));
      }
      _isFetchingMore = false;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Route Guard
    if (!authProvider.isLoggedIn || authProvider.userRole != 'buyer') {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF000613)),
              ),
              const SizedBox(height: 8),
              const Text('This portal is reserved for Buyer profiles only.'),
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

    // Filter dynamic pagination products list
    var filteredList = _paginatedProducts.where((p) {
      final matchesCategory = storeProvider.selectedCategory == 'All' || p.category == storeProvider.selectedCategory;
      final matchesSearch = p.name.toLowerCase().contains(storeProvider.searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(storeProvider.searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    final pages = [
      _buildStoreFeed(storeProvider, filteredList),
      const CategoriesScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppNavigationDrawer(
        currentIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      backgroundColor: const Color(0xFFFCF9F8),
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000), // Colors.black.withOpacity(0.05)
              blurRadius: 10,
              offset: Offset(0, -2),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF000613),
          unselectedItemColor: const Color(0xFF43474E),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined),
              activeIcon: Icon(Icons.category),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.shopping_cart_outlined),
                  if (storeProvider.cart.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Color(0xFFBA1A1A), shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text(
                          '${storeProvider.cart.fold(0, (sum, item) => sum + item.quantity)}',
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              activeIcon: const Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreFeed(StoreProvider provider, List<Product> list) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text(
          'NAND STORE',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Color(0xFF000613)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistScreen()),
              );
            },
          ),
          // Notification Bell icon with unread notifications count badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                },
              ),
              if (provider.unreadNotificationsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xFF7F5700),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                    child: Text(
                      '${provider.unreadNotificationsCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF000613),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Search Input Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F3F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFC4C6CF)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SearchScreen()),
                            );
                          },
                          child: Row(
                            children: const [
                              Icon(Icons.search, color: Color(0xFF43474E)),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Search for products, brands...',
                                  style: TextStyle(color: Color(0xFF43474E), fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final result = await showDialog<String>(
                            context: context,
                            builder: (_) => const VoiceSearchDialog(),
                          );
                          if (result != null && result.isNotEmpty && mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SearchScreen(initialQuery: result),
                              ),
                            );
                          }
                        },
                        child: const Icon(Icons.mic, color: Color(0xFF43474E)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (_isLoading) ...[
                  // Skeleton Loading Placeholder
                  _buildSkeletonLoader(),
                ] else ...[
                  // ── AR Promo Banner ───────────────────────────────────────
                  _buildARPromoBanner(context),
                  const SizedBox(height: 16),
                  // Summer Collection Banner
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBn4ljXmOxsRSs7oSTNLVT-Jk__4Hb58g0GN7w-uuPUph_EqPELyMGez6bDRlhH0_-wM_gt-fceVHjWEpS2tiy7vQP6xB_aYEKTpBcTy7ltdUjUsSc8fgSht4ma_9x5zJ46VVSIRQfI8JQrWVAIupEQ9GjxKrX8qHgfpKr6qXXJfMdm7gnHTuWiewtyXL1JYuufQmCUMehnhtiewYA9ebrhQdlqgCxYfoXMOOp7n5dZJ4alQfRmH0dGcgYk6dq8QMwfTwMBQp_FZA',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [Colors.black.withValues(alpha: 0.75), Colors.transparent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'LIMITED TIME OFFER',
                            style: TextStyle(color: Color(0xFFFFB62C), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Summer Essence\nCollection',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.2),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Up to 40% off on premium items.',
                            style: TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFB62C),
                              foregroundColor: const Color(0xFF000613),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: () {},
                            child: const Text('Shop Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Flash Sale Row Section
                  _buildFlashSaleSection(provider),
                  const SizedBox(height: 25),

                  // Category pills row
                  const Text(
                    'Browse Categories',
                    style: TextStyle(color: Color(0xFF000613), fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final selected = provider.selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: selected,
                            selectedColor: const Color(0xFF000613),
                            labelStyle: TextStyle(
                              color: selected ? Colors.white : const Color(0xFF43474E),
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 11,
                            ),
                            backgroundColor: const Color(0xFFF6F3F2),
                            onSelected: (val) {
                              provider.setCategory(category);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Grid header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Featured Products',
                        style: TextStyle(color: Color(0xFF000613), fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${list.length} Items',
                        style: const TextStyle(color: Color(0xFF43474E), fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Responsive Column grid builder based on parent width
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      int crossAxisCount = 2;
                      if (width >= 900) {
                        crossAxisCount = 4;
                      } else if (width >= 600) {
                        crossAxisCount = 3;
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final product = list[index];
                          return _buildProductCard(context, provider, product);
                        },
                      );
                    },
                  ),

                  if (_isFetchingMore) ...[
                    // Bottom pagination loader
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF000613),
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),

                  // Newsletter Bento section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF000613),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Join the NAND Circle',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Get exclusive early access to drops and member-only pricing.',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Email address',
                                  hintStyle: const TextStyle(color: Colors.white30),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  filled: true,
                                  fillColor: Colors.white.withValues(alpha: 0.1),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFFFFB62C)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFB62C),
                                foregroundColor: const Color(0xFF000613),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {},
                              child: const Text('Join', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlashSaleSection(StoreProvider provider) {
    // Select products under Flash Sale
    final flashProducts = dummyProducts.where((p) => p.price < 500).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  '⚡ FLASH SALE',
                  style: TextStyle(color: Color(0xFF7F5700), fontWeight: FontWeight.w800, fontSize: 15),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF000613),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatDuration(_flashSaleTimeLeft),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
            const Text(
              'Ends soon',
              style: TextStyle(color: Color(0xFF43474E), fontSize: 11, fontWeight: FontWeight.w500),
            )
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: flashProducts.length,
            itemBuilder: (context, index) {
              final p = flashProducts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
                  );
                },
                child: Container(
                  width: 250,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(10),
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
                          width: 70,
                          height: 70,
                          child: p.images.isNotEmpty
                              ? Image.network(
                                  p.images.first,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, _e) => Container(
                                    color: const Color(0xFFF6F3F2),
                                    child: Icon(
                                      p.category == 'Electronics' ? Icons.devices :
                                      p.category == 'Fashion' ? Icons.checkroom :
                                      p.category == 'Home' ? Icons.home :
                                      p.category == 'Beauty' ? Icons.content_cut : Icons.watch,
                                      color: const Color(0xFF000613),
                                      size: 28,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: const Color(0xFFF6F3F2),
                                  child: Icon(
                                    p.category == 'Electronics' ? Icons.devices :
                                    p.category == 'Fashion' ? Icons.checkroom :
                                    p.category == 'Home' ? Icons.home :
                                    p.category == 'Beauty' ? Icons.content_cut : Icons.watch,
                                    color: const Color(0xFF000613),
                                    size: 28,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF000613)),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '\$${p.price.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Color(0xFF7F5700), fontWeight: FontWeight.w800, fontSize: 13),
                                ),
                                if (p.oldPrice > 0) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '\$${p.oldPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Color(0xFF43474E), fontSize: 10, decoration: TextDecoration.lineThrough),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB62C),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'FLASH OFFER',
                                style: TextStyle(color: Color(0xFF000613), fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            )
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
      ],
    );
  }

  Widget _buildSkeletonLoader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner placeholder
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF0EDED),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 25),
        // Title placeholder
        Container(width: 120, height: 16, color: const Color(0xFFF0EDED)),
        const SizedBox(height: 12),
        // Chips placeholder
        Row(
          children: List.generate(4, (index) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              width: 70,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EDED),
                borderRadius: BorderRadius.circular(16),
              ),
            );
          }),
        ),
        const SizedBox(height: 25),
        // Grid cards placeholders
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFC4C6CF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF6F3F2),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: 100, height: 12, color: const Color(0xFFF0EDED)),
                          const SizedBox(height: 6),
                          Container(width: 50, height: 10, color: const Color(0xFFF0EDED)),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(width: 40, height: 14, color: const Color(0xFFF0EDED)),
                              Container(width: 28, height: 28, decoration: BoxDecoration(color: const Color(0xFFF0EDED), borderRadius: BorderRadius.circular(8))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, StoreProvider provider, Product product) {
    return ProductCard(product: product);
  }

  Widget _buildARPromoBanner(BuildContext context) {
    final categories = ['Electronics', 'Fashion', 'Home', 'Accessories'];

    return GestureDetector(
      onTap: () {
        // Open AR with the first featured product if none tapped
        final storeProvider = Provider.of<StoreProvider>(context, listen: false);
        final firstProduct = storeProvider.products.isNotEmpty ? storeProvider.products.first : null;
        if (firstProduct != null) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => ARLandingScreen(product: firstProduct),
              transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF060C1A), Color(0xFF0D1B38), Color(0xFF0A1228)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00C8FF).withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C8FF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00C8FF).withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.view_in_ar, color: Color(0xFF00C8FF), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '✨ AR SHOPPING IS HERE',
                        style: TextStyle(
                          color: Color(0xFF00C8FF),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Try Before You Buy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C8FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'TRY AR',
                    style: TextStyle(
                      color: Color(0xFF060C1A),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'See products in your real space before you order.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),
            // Category quick-launch row
            Row(
              children: categories.map((cat) {
                final color = ARUtils.categoryARColor(cat);
                final icon = ARUtils.categoryARIcon(cat);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        final storeProvider = Provider.of<StoreProvider>(context, listen: false);
                        final catProduct = storeProvider.products.firstWhere(
                          (p) => p.category == cat,
                          orElse: () => storeProvider.products.first,
                        );
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => ARLandingScreen(product: catProduct),
                            transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: color.withValues(alpha: 0.25)),
                        ),
                        child: Column(
                          children: [
                            Icon(icon, color: color, size: 16),
                            const SizedBox(height: 3),
                            Text(
                              cat == 'Electronics' ? 'Tech' : cat == 'Accessories' ? 'Acc' : cat,
                              style: TextStyle(
                                color: color,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

