import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/store_models.dart';
import '../providers/ar_provider.dart';
import '../providers/store_provider.dart';
import '../core/utils/ar_utils.dart';
import '../widgets/ar_product_overlay.dart';
import '../widgets/ar_controls_panel.dart';

/// Main AR View Screen — simulated AR with live camera-like background + product overlays.
/// Uses a gradient/animated background to simulate camera feed (no camera plugin needed,
/// keeping the app cross-platform and avoiding heavy native dependencies).
class ARViewScreen extends StatefulWidget {
  final Product product;

  const ARViewScreen({super.key, required this.product});

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen>
    with TickerProviderStateMixin {
  late ARProvider _arProvider;
  bool _isScanning = true;
  bool _showSnapshotFlash = false;
  String? _snapshotFeedback;

  // Grid/scan animation
  late AnimationController _gridCtrl;
  late Animation<double> _gridAnim;

  // Snapshot flash
  late AnimationController _flashCtrl;
  late Animation<double> _flashAnim;

  // AR background animation (simulates real-world camera by animating subtle gradient)
  late AnimationController _bgCtrl;
  late Animation<double> _bgAnim;

  @override
  void initState() {
    super.initState();

    _arProvider = context.read<ARProvider>();

    _gridCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _gridAnim = CurvedAnimation(parent: _gridCtrl, curve: Curves.linear);

    _flashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flashAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut),
    );

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _bgAnim = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut);

    // Add product to AR session after the scanning animation completes
    _arProvider.resetSession();
  }

  @override
  void dispose() {
    _gridCtrl.dispose();
    _flashCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  void _onScanComplete() {
    if (!mounted) return;
    setState(() => _isScanning = false);
    // Add product at center
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        final size = MediaQuery.of(context).size;
        _arProvider.addProduct(widget.product, size);
      }
    });
  }

  void _handleSnapshot() async {
    setState(() => _showSnapshotFlash = true);
    _flashCtrl.forward(from: 0).then((_) => _flashCtrl.reverse());

    // Simulate saving snapshot
    await Future.delayed(const Duration(milliseconds: 600));
    if (context.mounted) {
      setState(() {
        _showSnapshotFlash = false;
        _snapshotFeedback = '📸 AR Photo saved!';
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _snapshotFeedback = null);
    }
  }

  void _handleAddToCart() {
    final storeProvider = context.read<StoreProvider>();
    storeProvider.addToCart(widget.product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${widget.product.name} added to cart!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF000613),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final categoryColor = ARUtils.categoryARColor(widget.product.category);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<ARProvider>(
        builder: (context, ar, _) {
          return Stack(
            children: [
              // ── Simulated Camera Background ──────────────────────────────
              _buildSimulatedCamera(size, categoryColor),

              // ── AR Guide Grid (CustomPaint) ───────────────────────────────
              if (!_isScanning && ar.showGuideLines)
                AnimatedBuilder(
                  animation: _gridAnim,
                  builder: (context, _) => CustomPaint(
                    size: size,
                    painter: ARGridPainter(
                      animationValue: _gridAnim.value,
                      showGrid: ar.showGuideLines,
                      color: categoryColor,
                    ),
                  ),
                ),

              // ── Product Overlays ─────────────────────────────────────────
              if (!_isScanning)
                ...ar.arProducts.asMap().entries.map((entry) {
                  final i = entry.key;
                  final state = entry.value;
                  return ARProductOverlay(
                    key: ValueKey('ar_product_$i'),
                    arState: state,
                    index: i,
                    screenSize: size,
                    shadowEnabled: ar.shadowEnabled,
                    tiltX: ar.tiltX,
                    tiltY: ar.tiltY,
                    onTap: () => ar.selectProduct(i),
                    onDrag: (delta) => ar.updateProductPosition(i, delta, size),
                    onScale: (scale) => ar.updateProductScale(i, scale),
                    onRotate: (angle) => ar.updateProductRotation(i, angle),
                  );
                }),

              // ── Scanning Overlay ─────────────────────────────────────────
              if (_isScanning)
                ARScanningOverlay(onComplete: _onScanComplete),

              // ── Top HUD Bar ──────────────────────────────────────────────
              if (!_isScanning)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildTopHUD(ar, categoryColor),
                ),

              // ── Bottom Controls ──────────────────────────────────────────
              if (!_isScanning)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ARControlsPanel(
                    arProvider: ar,
                    product: widget.product,
                    onAddToCart: _handleAddToCart,
                    onSnapshot: _handleSnapshot,
                    onReset: () {
                      ar.resetSession();
                      ar.addProduct(widget.product, size);
                    },
                    onClose: () => Navigator.pop(context),
                  ),
                ),

              // ── Snapshot Flash ───────────────────────────────────────────
              if (_showSnapshotFlash)
                AnimatedBuilder(
                  animation: _flashAnim,
                  builder: (context, _) => Container(
                    color: Colors.white.withValues(alpha: _flashAnim.value * 0.8),
                  ),
                ),

              // ── Snapshot Feedback Toast ──────────────────────────────────
              if (_snapshotFeedback != null)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 70,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      tween: Tween(begin: 0, end: 1),
                      builder: (_, v, child) => Opacity(opacity: v, child: child),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _snapshotFeedback!,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Selected product delete action ───────────────────────────
              if (!_isScanning && ar.selectedProductIndex >= 0 && ar.arProducts.length > 1)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 70,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => ar.removeProduct(ar.selectedProductIndex),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Animated gradient background simulating a camera feed environment.
  Widget _buildSimulatedCamera(Size size, Color accentColor) {
    return AnimatedBuilder(
      animation: _bgAnim,
      builder: (context, _) {
        final t = _bgAnim.value;
        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(
                -1 + t * 0.4,
                -1 + t * 0.2,
              ),
              end: Alignment(
                1 - t * 0.3,
                1 - t * 0.15,
              ),
              colors: const [
                Color(0xFF0A0E1A),
                Color(0xFF12182E),
                Color(0xFF0D1520),
                Color(0xFF0A1228),
                Color(0xFF101828),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Subtle ambient glow blobs
              Positioned(
                left: size.width * (0.1 + t * 0.3),
                top: size.height * (0.2 + t * 0.15),
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accentColor.withValues(alpha: 0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: size.width * (0.05 + t * 0.2),
                bottom: size.height * (0.3 + t * 0.1),
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF9B59F5).withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Room-like floor horizon line
              Positioned(
                left: 0,
                right: 0,
                top: size.height * 0.52,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Floor area (slightly lighter)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: size.height * 0.52,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.03),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopHUD(ARProvider ar, Color categoryColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Back
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: categoryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: categoryColor, blurRadius: 4),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'AR MODE ACTIVE',
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Camera toggle (front/back)
              GestureDetector(
                onTap: () => ar.toggleCamera(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Icon(
                    ar.isFrontCamera ? Icons.camera_front : Icons.camera_rear,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Flash toggle
              GestureDetector(
                onTap: () => ar.toggleFlash(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: ar.isFlashOn
                        ? categoryColor.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ar.isFlashOn ? categoryColor : Colors.white12,
                    ),
                  ),
                  child: Icon(
                    ar.isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: ar.isFlashOn ? categoryColor : Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
