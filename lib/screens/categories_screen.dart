import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../models/store_models.dart';
import '../widgets/product_card.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String? _activeCategory;
  String _activeSubcategory = 'All';
  String _localSearchQuery = '';
  String _localSortBy = 'Popularity';
  double _priceLimit = 1500.00;
  double _minRating = 0.0;

  final List<Map<String, dynamic>> _cats = const [
    {
      'name': 'Electronics',
      'icon': Icons.devices,
      'description': 'Premium gadgets, sound setups, and smart gadgets.',
      'subcategories': ['All', 'Phones', 'Audio', 'Pro System'],
      'banner': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCLUVQ7shhDLdjT3rjXobnOb5l9R7_8H-uE3D6uFQUH3Lbe5cQLJT6zklK6Qp5yAnrHr1Iwxg3EJfNfZAu1d5kHtDCzgusjxgKIejp-lKVt40I7GzqDROYZeqCl8XgKNvoITDQiAqrrICliWddbJRt8VG1E_s7K_8ZNabDyq-gOMu53E8vH8t2uaS-smyf-iCL5GmahtkFA2FBpNBkPIk5f8hEUVJCi4n10S3NV44BYrD8qs7x-QfNch7KpFa_Y2kdbHxezk1pG-A'
    },
    {
      'name': 'Fashion',
      'icon': Icons.checkroom,
      'description': 'Modern garments and premium quality designer apparel.',
      'subcategories': ['All', 'Apparel', 'Outfits'],
      'banner': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBn4ljXmOxsRSs7oSTNLVT-Jk__4Hb58g0GN7w-uuPUph_EqPELyMGez6bDRlhH0_-wM_gt-fceVHjWEpS2tiy7vQP6xB_aYEKTpBcTy7ltdUjUsSc8fgSht4ma_9x5zJ46VVSIRQfI8JQrWVAIupEQ9GjxKrX8qHgfpKr6qXXJfMdm7gnHTuWiewtyXL1JYuufQmCUMehnhtiewYA9ebrhQdlqgCxYfoXMOOp7n5dZJ4alQfRmH0dGcgYk6dq8QMwfTwMBQp_FZA'
    },
    {
      'name': 'Home',
      'icon': Icons.home,
      'description': 'Minimalist diffusers, lights, and modern living accessories.',
      'subcategories': ['All', 'Diffusers', 'Decor'],
      'banner': 'https://lh3.googleusercontent.com/aida-public/AB6AXuC-0pn5dXIHqenQyQ-yAld1lhzOZ-X0HbG590xQge-kvDIQJu2B525lvIF7qih0v3YlQzfWBXb97R0C9K5gJYPQi5gCuFfLg3s_If0O5XU7YFch7jhWeCNG_VxY5rfA1gWMBFPZhl_EnsFJizWQH78-tXbSMaMFlpyz-eyE_jITtw1SPk03U2N-GGBJ8Dnhe16zNC5UKUb4mhWjqzZWvYOqMFaErGV0lIqFecnIwUnSLiOzvfoE1TwgyUja-C2IcodkJiP9bfT2Ow'
    },
    {
      'name': 'Beauty',
      'icon': Icons.content_cut,
      'description': 'Calm, airy materials and essential cosmetics.',
      'subcategories': ['All', 'Skincare', 'Mist'],
      'banner': 'https://lh3.googleusercontent.com/aida-public/AB6AXuC-0pn5dXIHqenQyQ-yAld1lhzOZ-X0HbG590xQge-kvDIQJu2B525lvIF7qih0v3YlQzfWBXb97R0C9K5gJYPQi5gCuFfLg3s_If0O5XU7YFch7jhWeCNG_VxY5rfA1gWMBFPZhl_EnsFJizWQH78-tXbSMaMFlpyz-eyE_jITtw1SPk03U2N-GGBJ8Dnhe16zNC5UKUb4mhWjqzZWvYOqMFaErGV0lIqFecnIwUnSLiOzvfoE1TwgyUja-C2IcodkJiP9bfT2Ow'
    },
    {
      'name': 'Accessories',
      'icon': Icons.watch,
      'description': 'Luxurious watches, smart wallets, and tracking tags.',
      'subcategories': ['All', 'Watches', 'Wallets', 'Tracker'],
      'banner': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBUmp8fb2VLUO5sxytW3HoRaqWwq3ok3UPBq9le0zUOcXqy0X4TXpcFGN_bO5bwScObsO-dTMRK6C57QJMHWp5WMvl_-ld-Kbh1ZaPQMxh3sIXDoa_sfB3abpSUpTcnZVpGY7BCxqUjW5nJOxNPAW2i-rysHiZoOkQ_JOfQktN6g1GEafErnKa2d1twhud9m0pkTkTNxItDATITiA7hscq-RzSG1SkjhOzzihW77dcmWeXUVZfWhIRHtKiLZH4p-NXLMF82p4f99A'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: AppBar(
        title: Text(_activeCategory ?? 'Explore Categories'),
        leading: _activeCategory != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _activeCategory = null;
                    _activeSubcategory = 'All';
                  });
                },
              )
            : null,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _activeCategory == null
            ? _buildOverviewGrid(storeProvider)
            : _buildDetailsExplorer(storeProvider),
      ),
    );
  }

  Widget _buildOverviewGrid(StoreProvider storeProvider) {
    return GridView.builder(
      key: const ValueKey('OverviewGrid'),
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.05,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _cats.length,
      itemBuilder: (context, index) {
        final cat = _cats[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _activeCategory = cat['name'];
              _activeSubcategory = 'All';
              _localSearchQuery = '';
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFC4C6CF), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x03000000), // Colors.black.withOpacity(0.01)
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF6F3F2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    cat['icon'] as IconData,
                    color: const Color(0xFF000613),
                    size: 26,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  cat['name'] as String,
                  style: const TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailsExplorer(StoreProvider storeProvider) {
    final catData = _cats.firstWhere((element) => element['name'] == _activeCategory);
    final subcategories = catData['subcategories'] as List<String>;

    // Filter products locally based on category, subcategory, search, price range, and rating
    var explorerList = dummyProducts.where((p) {
      final matchesCategory = p.category == _activeCategory;
      final matchesSubcategory = _activeSubcategory == 'All' ||
          p.name.toLowerCase().contains(_activeSubcategory.toLowerCase()) ||
          p.description.toLowerCase().contains(_activeSubcategory.toLowerCase());
      final matchesSearch = _localSearchQuery.isEmpty ||
          p.name.toLowerCase().contains(_localSearchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_localSearchQuery.toLowerCase());
      final matchesPrice = p.price <= _priceLimit;
      final matchesRating = p.rating >= _minRating;

      return matchesCategory && matchesSubcategory && matchesSearch && matchesPrice && matchesRating;
    }).toList();

    // Sorting operations
    if (_localSortBy == 'Price Low to High') {
      explorerList.sort((a, b) => a.price.compareTo(b.price));
    } else if (_localSortBy == 'Price High to Low') {
      explorerList.sort((a, b) => b.price.compareTo(a.price));
    } else if (_localSortBy == 'Rating') {
      explorerList.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return Column(
      key: ValueKey('DetailsExplorer_$_activeCategory'),
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Banner Card
                Container(
                  height: 120,
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(catData['banner'] as String),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          catData['name'] as String,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          catData['description'] as String,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),

                // Inline Search Box inside details explorer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F3F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFC4C6CF)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 18, color: Color(0xFF43474E)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (val) {
                              setState(() {
                                _localSearchQuery = val;
                              });
                            },
                            style: const TextStyle(color: Color(0xFF1C1B1B), fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: 'Search within category...',
                              hintStyle: TextStyle(color: Color(0xFF43474E)),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Subcategories Chips Selection
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: subcategories.length,
                    itemBuilder: (context, index) {
                      final sub = subcategories[index];
                      final selected = _activeSubcategory == sub;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(sub),
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
                              _activeSubcategory = sub;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Filters summary and Sort bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Filters sheet trigger button
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _showFiltersSheet(context),
                        icon: const Icon(Icons.filter_list, size: 14, color: Color(0xFF000613)),
                        label: const Text('Filters', style: TextStyle(color: Color(0xFF000613), fontSize: 11)),
                      ),
                      // Sort selector dropdown
                      DropdownButton<String>(
                        value: _localSortBy,
                        underline: const SizedBox(),
                        style: const TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.bold, fontSize: 12),
                        icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF000613)),
                        items: ['Popularity', 'Price Low to High', 'Price High to Low', 'Rating'].map((val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        }).toList(),
                        onChanged: (newVal) {
                          if (newVal != null) {
                            setState(() {
                              _localSortBy = newVal;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Explorer Product Grid Items list
                if (explorerList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No products found matching filters.',
                        style: TextStyle(color: Color(0xFF43474E), fontSize: 12),
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: explorerList.length,
                    itemBuilder: (context, index) {
                      final p = explorerList[index];
                      return _buildProductCard(context, storeProvider, p);
                    },
                  ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showFiltersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Options',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF000613)),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _priceLimit = 1500.00;
                            _minRating = 0.0;
                          });
                          setState(() {});
                        },
                        child: const Text('Reset', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Max Price: \$${_priceLimit.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF43474E)),
                  ),
                  Slider(
                    value: _priceLimit,
                    min: 10.0,
                    max: 1500.0,
                    divisions: 15,
                    activeColor: const Color(0xFF000613),
                    inactiveColor: const Color(0xFFC4C6CF),
                    onChanged: (val) {
                      setModalState(() {
                        _priceLimit = val;
                      });
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Min Rating: ${_minRating.toStringAsFixed(1)} Stars',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF43474E)),
                  ),
                  Slider(
                    value: _minRating,
                    min: 0.0,
                    max: 5.0,
                    divisions: 10,
                    activeColor: const Color(0xFF000613),
                    inactiveColor: const Color(0xFFC4C6CF),
                    onChanged: (val) {
                      setModalState(() {
                        _minRating = val;
                      });
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF000613),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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

  Widget _buildProductCard(BuildContext context, StoreProvider provider, Product product) {
    return ProductCard(product: product);
  }
}
