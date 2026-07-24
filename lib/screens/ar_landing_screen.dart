import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/store_models.dart';
import 'ar_view_screen.dart';

/// AR Onboarding / Feature Discovery screen.
/// Shown the first time a user taps "View in AR".
class ARLandingScreen extends StatefulWidget {
  final Product product;

  const ARLandingScreen({super.key, required this.product});

  @override
  State<ARLandingScreen> createState() => _ARLandingScreenState();
}

class _ARLandingScreenState extends State<ARLandingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final List<_ARFeature> _features = [
    _ARFeature(
      icon: Icons.weekend_outlined,
      color: const Color(0xFF00C8FF),
      title: 'Place in Your Space',
      subtitle: 'See exactly how the product\nlooks in your room before buying.',
      gradient: [const Color(0xFF0D1B4A), const Color(0xFF0A2E4A)],
    ),
    _ARFeature(
      icon: Icons.face_outlined,
      color: const Color(0xFFFF6B9D),
      title: 'Virtual Try-On',
      subtitle: 'Try on fashion & accessories\nwith your front camera.',
      gradient: [const Color(0xFF3D0A2A), const Color(0xFF4A0A3A)],
    ),
    _ARFeature(
      icon: Icons.compare_outlined,
      color: const Color(0xFF5CFF8A),
      title: 'Compare Side-by-Side',
      subtitle: 'Place multiple products at once\nto compare them in real space.',
      gradient: [const Color(0xFF0A2E1A), const Color(0xFF0A3A20)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _launchAR() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ARViewScreen(product: widget.product),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Stack(
          children: [
            // Animated background
            _buildAnimatedBackground(),

            // Page content
            Column(
              children: [
                // Top bar
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: Color(0xFF00C8FF), size: 14),
                              const SizedBox(width: 6),
                              const Text(
                                'AR SHOPPING',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Skip button
                        TextButton(
                          onPressed: _launchAR,
                          child: const Text(
                            'Skip',
                            style: TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Floating product preview
                AnimatedBuilder(
                  animation: _floatAnim,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnim.value),
                      child: child,
                    );
                  },
                  child: _buildProductPreview(),
                ),

                const SizedBox(height: 24),

                // Feature pages
                SizedBox(
                  height: 180,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _features.length,
                    itemBuilder: (context, index) {
                      return _buildFeaturePage(_features[index]);
                    },
                  ),
                ),

                // Page indicators
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_features.length, (i) {
                    final isActive = i == _currentPage;
                    final color = _features[_currentPage].color;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive ? color : Colors.white24,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),

                const Spacer(),

                // CTA Button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _features[_currentPage].color,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _launchAR,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.camera_alt, size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Start AR Experience',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Camera permission required for AR features',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    final color = _features[_currentPage].color;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.5,
          colors: [
            color.withValues(alpha: 0.15),
            Colors.black,
          ],
        ),
      ),
      child: CustomPaint(
        painter: _StarfieldPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildProductPreview() {
    final color = _features[_currentPage].color;
    return Container(
      width: 180,
      height: 180,
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: widget.product.images.isNotEmpty
            ? Image.network(
                widget.product.images.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, _) => _buildFallbackImage(color),
              )
            : _buildFallbackImage(color),
      ),
    );
  }

  Widget _buildFallbackImage(Color color) {
    return Container(
      color: const Color(0xFF0D0D1A),
      child: Icon(
        Icons.shopping_bag_outlined,
        color: color,
        size: 60,
      ),
    );
  }

  Widget _buildFeaturePage(_ARFeature feature) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: feature.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: feature.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: feature.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: feature.color.withValues(alpha: 0.4)),
            ),
            child: Icon(feature.icon, color: feature.color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  feature.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ARFeature {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const _ARFeature({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}

/// Simple starfield background painter.
class _StarfieldPainter extends CustomPainter {
  final math.Random _rng = math.Random(99);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (int i = 0; i < 60; i++) {
      final x = _rng.nextDouble() * size.width;
      final y = _rng.nextDouble() * size.height;
      final radius = _rng.nextDouble() * 1.2;
      final opacity = _rng.nextDouble() * 0.4 + 0.1;
      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) => false;
}
