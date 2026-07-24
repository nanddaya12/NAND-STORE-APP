import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../models/store_models.dart';
import '../widgets/product_card.dart';
import '../widgets/voice_search_dialog.dart';
import 'seller/seller_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _searchController;
  bool _hasSubmitted = false;
  String _activeCategory = 'All';
  String _activeSortBy = 'Popularity';
  double _priceLimit = 1500.00;
  double _minRating = 0.0;
  int _currentSearchTab = 0; // 0 for Products, 1 for Sellers/Shops

  final List<String> _trendingKeywords = const [
    'X-1 Pro',
    'Audio Z1',
    'Gold Watch',
    'Aura Mist',
    'Smart Wallet'
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    if (widget.initialQuery != null) {
      _hasSubmitted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = Provider.of<StoreProvider>(context, listen: false);
        provider.addToSearchHistory(widget.initialQuery!);
        provider.setSearchQuery(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmit(StoreProvider provider, String query) {
    if (query.trim().isEmpty) return;
    provider.addToSearchHistory(query);
    setState(() {
      _hasSubmitted = true;
    });
  }

  void _triggerVoiceSearch(StoreProvider provider) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => const VoiceSearchDialog(),
    );
    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        _searchController.text = result;
        _hasSubmitted = true;
      });
      provider.addToSearchHistory(result);
      provider.setSearchQuery(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final String typedQuery = _searchController.text;

    // Autosuggestions matched keywords
    final suggestions = dummyProducts.where((p) {
      return typedQuery.isNotEmpty && p.name.toLowerCase().contains(typedQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F3F2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(color: Color(0xFF1C1B1B), fontSize: 14),
                  textInputAction: TextInputAction.search,
                  onChanged: (val) {
                    setState(() {
                      _hasSubmitted = false;
                    });
                  },
                  onSubmitted: (val) => _onSearchSubmit(storeProvider, val),
                  decoration: const InputDecoration(
                    hintText: 'Search NAND catalog...',
                    hintStyle: TextStyle(color: Color(0xFF43474E)),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.mic, color: Color(0xFF000613), size: 20),
                onPressed: () => _triggerVoiceSearch(storeProvider),
              ),
            ],
          ),
        ),
      ),
      body: _hasSubmitted
          ? _buildResultsView(storeProvider)
          : (typedQuery.isNotEmpty
              ? _buildSuggestionsView(storeProvider, suggestions)
              : _buildLandingView(storeProvider)),
    );
  }

  Widget _buildLandingView(StoreProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches Header
          if (provider.searchHistory.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF000613)),
                ),
                TextButton(
                  onPressed: provider.clearSearchHistory,
                  child: const Text('Clear All', style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Tags Row of recent search keywords
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.searchHistory.map((query) {
                return InputChip(
                  padding: EdgeInsets.zero,
                  label: Text(query, style: const TextStyle(fontSize: 11)),
                  backgroundColor: Colors.white,
                  deleteIcon: const Icon(Icons.close, size: 12, color: Color(0xFF43474E)),
                  onDeleted: () => provider.removeFromSearchHistory(query),
                  labelStyle: const TextStyle(color: Color(0xFF000613), fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFFC4C6CF))),
                  onPressed: () {
                    setState(() {
                      _searchController.text = query;
                      _hasSubmitted = true;
                    });
                    provider.addToSearchHistory(query);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Trending Searches list
          const Text(
            'Trending Searches',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF000613)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _trendingKeywords.map((keyword) {
              return ActionChip(
                label: Text(keyword, style: const TextStyle(fontSize: 11)),
                backgroundColor: const Color(0xFFF6F3F2),
                labelStyle: const TextStyle(color: Color(0xFF43474E), fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFFC4C6CF))),
                onPressed: () {
                  setState(() {
                    _searchController.text = keyword;
                    _hasSubmitted = true;
                  });
                  provider.addToSearchHistory(keyword);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsView(StoreProvider provider, List<Product> list) {
    if (list.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('No matching suggestions found.', style: TextStyle(color: Color(0xFF43474E), fontSize: 13)),
        ),
      );
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final p = list[index];
        return ListTile(
          leading: const Icon(Icons.search, color: Color(0xFF43474E), size: 18),
          title: Text(p.name, style: const TextStyle(color: Color(0xFF000613), fontSize: 13, fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.arrow_outward, size: 14, color: Color(0xFF43474E)),
          onTap: () {
            setState(() {
              _searchController.text = p.name;
              _hasSubmitted = true;
            });
            provider.addToSearchHistory(p.name);
          },
        );
      },
    );
  }

  Widget _buildSearchTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ChoiceChip(
              label: const Center(child: Text('Products', style: TextStyle(fontSize: 12))),
              selected: _currentSearchTab == 0,
              selectedColor: const Color(0xFF000613),
              labelStyle: TextStyle(
                color: _currentSearchTab == 0 ? Colors.white : const Color(0xFF43474E),
                fontWeight: _currentSearchTab == 0 ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: const Color(0xFFF6F3F2),
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _currentSearchTab = 0;
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ChoiceChip(
              label: const Center(child: Text('Sellers / Shops', style: TextStyle(fontSize: 12))),
              selected: _currentSearchTab == 1,
              selectedColor: const Color(0xFF000613),
              labelStyle: TextStyle(
                color: _currentSearchTab == 1 ? Colors.white : const Color(0xFF43474E),
                fontWeight: _currentSearchTab == 1 ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: const Color(0xFFF6F3F2),
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _currentSearchTab = 1;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(StoreProvider storeProvider) {
    final query = _searchController.text;

    // If Sellers Tab is active
    if (_currentSearchTab == 1) {
      final sellersList = storeProvider.sellers;
      return Column(
        children: [
          _buildSearchTabs(),
          const SizedBox(height: 12),
          Expanded(
            child: sellersList.isEmpty
                ? const Center(
                    child: Text('No shops found matching query.', style: TextStyle(color: Color(0xFF43474E), fontSize: 12)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sellersList.length,
                    itemBuilder: (context, index) {
                      final s = sellersList[index];
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFC4C6CF), width: 0.5),
                        ),
                        elevation: 0,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFFFFB62C),
                            backgroundImage: NetworkImage(s.profileImage),
                            child: s.profileImage.isEmpty ? const Icon(Icons.store, color: Color(0xFF000613)) : null,
                          ),
                          title: Text(
                            s.shopName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF000613)),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                s.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Color(0xFF43474E), fontSize: 11),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Color(0xFFFFB62C), size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${s.rating}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF000613)),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.email_outlined, size: 12, color: Color(0xFF43474E)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      s.email,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 10, color: Color(0xFF43474E)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Color(0xFF000613)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => SellerProfileScreen(seller: s)),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    }

    final List<String> categories = ['All', 'Electronics', 'Fashion', 'Home', 'Accessories'];

    // Local results filtering
    var resultsList = storeProvider.allProducts.where((p) {
      final matchesCategory = _activeCategory == 'All' || p.category == _activeCategory;
      final matchesQuery = p.name.toLowerCase().contains(query.toLowerCase()) ||
          p.description.toLowerCase().contains(query.toLowerCase());
      final matchesPrice = p.price <= _priceLimit;
      final matchesRating = p.rating >= _minRating;

      return matchesCategory && matchesQuery && matchesPrice && matchesRating;
    }).toList();

    // Local sorting
    if (_activeSortBy == 'Price Low to High') {
      resultsList.sort((a, b) => a.price.compareTo(b.price));
    } else if (_activeSortBy == 'Price High to Low') {
      resultsList.sort((a, b) => b.price.compareTo(a.price));
    } else if (_activeSortBy == 'Rating') {
      resultsList.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return Column(
      children: [
        _buildSearchTabs(),
        const SizedBox(height: 4),
        
        // Categories Choice Chips
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final selected = _activeCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(cat),
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
                      _activeCategory = cat;
                    });
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Filter and Sort row controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _showFiltersSheet(context),
                icon: const Icon(Icons.filter_list, size: 14, color: Color(0xFF000613)),
                label: const Text('Filters', style: TextStyle(color: Color(0xFF000613), fontSize: 11)),
              ),
              DropdownButton<String>(
                value: _activeSortBy,
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
                      _activeSortBy = newVal;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Product Grid Results
        Expanded(
          child: resultsList.isEmpty
              ? const Center(
                  child: Text('No products found matching query.', style: TextStyle(color: Color(0xFF43474E), fontSize: 12)),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: resultsList.length,
                  itemBuilder: (context, index) {
                    final p = resultsList[index];
                    return _buildProductCard(context, storeProvider, p);
                  },
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
