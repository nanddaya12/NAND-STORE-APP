import 'package:flutter/material.dart';
import 'role_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  final List<Map<String, dynamic>> _slides = const [
    {
      'title': 'Premium Quality Catalog',
      'description': 'Browse through a handpicked selection of top-tier electronics, fashionwear, and luxury items customized to your needs.',
      'icon': Icons.devices_other,
    },
    {
      'title': 'Secure Checkout Pathways',
      'description': 'Transact safely with standard 256-bit encrypted gateway pipelines supporting credit cards, PayPal, and offline COD options.',
      'icon': Icons.security,
    },
    {
      'title': 'Fast & Safe Logistics',
      'description': 'Enjoy free express deliveries on high-end checkout orders shipped in priority premium packaging slots directly to your door.',
      'icon': Icons.local_shipping_outlined,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPageIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _onSkip();
    }
  }

  void _onSkip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Skip header button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _onSkip,
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Color(0xFF43474E), fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (idx) {
                    setState(() {
                      _currentPageIndex = idx;
                    });
                  },
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF6F3F2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            slide['icon'] as IconData,
                            size: 64,
                            color: const Color(0xFF000613),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          slide['title'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF000613)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            slide['description'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF43474E), fontSize: 13, height: 1.5),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators dots
                  Row(
                    children: List.generate(_slides.length, (idx) {
                      final active = _currentPageIndex == idx;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active ? const Color(0xFF000613) : const Color(0xFFC4C6CF),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  // Next action button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000613),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: _onNext,
                    child: Text(
                      _currentPageIndex == _slides.length - 1 ? 'Get Started' : 'Next',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
