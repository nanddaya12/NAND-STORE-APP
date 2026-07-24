import 'package:flutter/material.dart';
import '../providers/ar_provider.dart';
import '../core/utils/ar_utils.dart';
import '../features/catalog/domain/entities/product.dart';

/// Renders a single AR product overlay on the camera feed.
/// Handles its own drag + scale + rotate gestures.
class ARProductOverlay extends StatefulWidget {
  final ARProductState arState;
  final int index;
  final Size screenSize;
  final bool shadowEnabled;
  final double tiltX;
  final double tiltY;
  final VoidCallback onTap;
  final Function(Offset delta) onDrag;
  final Function(double scale) onScale;
  final Function(double angle) onRotate;

  const ARProductOverlay({
    super.key,
    required this.arState,
    required this.index,
    required this.screenSize,
    required this.shadowEnabled,
    required this.tiltX,
    required this.tiltY,
    required this.onTap,
    required this.onDrag,
    required this.onScale,
    required this.onRotate,
  });

  @override
  State<ARProductOverlay> createState() => _ARProductOverlayState();
}

class _ARProductOverlayState extends State<ARProductOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late Animation<double> _bounceAnim;

  double _lastScale = 1.0;
  double _lastAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.elasticOut),
    );
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.arState;
    final product = state.product;
    final pos = Offset(
      state.position.dx * widget.screenSize.width,
      state.position.dy * widget.screenSize.height,
    );

    // Product display size (base 180 scaled by state.scale)
    final baseSize = 180.0;
    final displaySize = baseSize * state.scale;

    // Tilt-based parallax offset
    final parallaxX = widget.tiltX * 12.0;
    final parallaxY = widget.tiltY * 12.0;

    final categoryColor = ARUtils.categoryARColor(product.category);

    return Positioned(
      left: pos.dx - displaySize / 2 + parallaxX,
      top: pos.dy - displaySize / 2 + parallaxY,
      child: GestureDetector(
        onTap: widget.onTap,
        onScaleStart: (details) {
          _lastScale = 1.0;
          _lastAngle = 0.0;
        },
        onScaleUpdate: (details) {
          // Drag
          if (details.pointerCount == 1) {
            widget.onDrag(details.focalPointDelta);
          }
          // Pinch scale
          if (details.scale != 1.0) {
            final scaleDelta = details.scale / _lastScale;
            widget.onScale(scaleDelta);
            _lastScale = details.scale;
          }
          // Rotation
          if (details.rotation != 0.0) {
            final angleDelta = details.rotation - _lastAngle;
            widget.onRotate(angleDelta);
            _lastAngle = details.rotation;
          }
        },
        child: AnimatedBuilder(
          animation: _bounceAnim,
          builder: (context, child) {
            return Transform.scale(
              scale: _bounceAnim.value,
              child: child,
            );
          },
          child: Transform(
            transform: ARUtils.applyPerspectiveTilt(
              tiltX: widget.tiltX,
              tiltY: widget.tiltY,
              depth: 0.0008,
              maxAngle: 0.12,
            ),
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: state.rotation,
              child: SizedBox(
                width: displaySize,
                height: displaySize,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Drop shadow (painted below)
                    if (widget.shadowEnabled)
                      Positioned(
                        bottom: -16,
                        left: displaySize * 0.15,
                        right: displaySize * 0.15,
                        child: Container(
                          height: displaySize * 0.12,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(displaySize),
                          ),
                        ),
                      ),

                    // Main product container
                    Container(
                      width: displaySize,
                      height: displaySize,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: state.isSelected
                            ? Border.all(color: categoryColor, width: 2)
                            : null,
                        boxShadow: state.isSelected
                            ? [
                                BoxShadow(
                                  color: categoryColor.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: product.images.isNotEmpty
                          ? Image.network(
                              product.images.first,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, _) => _buildFallbackIcon(product, categoryColor),
                            )
                          : _buildFallbackIcon(product, categoryColor),
                    ),

                    // "AR" corner badge
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'AR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    // Product name label at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.7),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Selection handles when selected
                    if (state.isSelected) ...[
                      // Corner handles
                      _buildHandle(const Alignment(-1, -1), categoryColor),
                      _buildHandle(const Alignment(1, -1), categoryColor),
                      _buildHandle(const Alignment(-1, 1), categoryColor),
                      _buildHandle(const Alignment(1, 1), categoryColor),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(Product product, Color color) {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: Icon(
        ARUtils.categoryARIcon(product.category),
        color: color,
        size: 60,
      ),
    );
  }

  Widget _buildHandle(Alignment alignment, Color color) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.7),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}

// ── AR Grid Painter ────────────────────────────────────────────────────────────

class ARGridPainter extends CustomPainter {
  final double animationValue;
  final bool showGrid;
  final Color color;

  ARGridPainter({
    required this.animationValue,
    this.showGrid = true,
    this.color = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (showGrid) {
      ARUtils.paintGuideGrid(canvas, size, color: color, opacity: 0.15);
    }
    // Scan line sweep
    final scanY = (animationValue * 1.2 - 0.1).clamp(0.0, 1.0);
    if (animationValue < 1.0) {
      ARUtils.paintScanLine(canvas, size, scanY);
    }
  }

  @override
  bool shouldRepaint(ARGridPainter old) =>
      old.animationValue != animationValue || old.showGrid != showGrid;
}

// ── AR Scanning Overlay ────────────────────────────────────────────────────────

/// Full-screen scanning animation shown while AR "initializes".
class ARScanningOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const ARScanningOverlay({super.key, required this.onComplete});

  @override
  State<ARScanningOverlay> createState() => _ARScanningOverlayState();
}

class _ARScanningOverlayState extends State<ARScanningOverlay>
    with TickerProviderStateMixin {
  late AnimationController _scanCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double> _scanAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scanAnim = CurvedAnimation(parent: _scanCtrl, curve: Curves.easeInOut);
    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(_fadeCtrl);

    _scanCtrl.forward().then((_) {
      _fadeCtrl.forward().then((_) => widget.onComplete());
    });
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scanAnim, _fadeAnim]),
      builder: (context, _) {
        return Opacity(
          opacity: _fadeAnim.value,
          child: Container(
            color: Colors.black.withValues(alpha: 0.6),
            child: CustomPaint(
              painter: ARGridPainter(
                animationValue: _scanAnim.value,
                showGrid: true,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        color: Color(0xFF00C8FF),
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Scanning Environment...',
                      style: TextStyle(
                        color: Color(0xFF00C8FF),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Point camera at a flat surface',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
