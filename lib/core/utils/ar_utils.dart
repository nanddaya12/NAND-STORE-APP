import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Utility functions for AR shopping features.
class ARUtils {
  ARUtils._();

  // ── Category Helpers ──────────────────────────────────────────────────────

  /// Returns true for categories that support "Try On" mode (front camera).
  static bool categorySupportsARTryOn(String category) {
    return category == 'Fashion' || category == 'Accessories';
  }

  /// Returns a category-specific icon for use in AR overlays.
  static IconData categoryARIcon(String category) {
    switch (category) {
      case 'Electronics':
        return Icons.devices;
      case 'Fashion':
        return Icons.checkroom;
      case 'Home':
        return Icons.chair;
      case 'Accessories':
        return Icons.watch;
      default:
        return Icons.shopping_bag;
    }
  }

  /// Returns color for AR overlay glow based on category.
  static Color categoryARColor(String category) {
    switch (category) {
      case 'Electronics':
        return const Color(0xFF00C8FF);
      case 'Fashion':
        return const Color(0xFFFF6B9D);
      case 'Home':
        return const Color(0xFF5CFF8A);
      case 'Accessories':
        return const Color(0xFFFFBB00);
      default:
        return const Color(0xFF9B59F5);
    }
  }

  // ── Scale Computation ─────────────────────────────────────────────────────

  /// Computes a smart initial scale so the product fits reasonably on screen.
  static double computeProductScale({
    required Size screenSize,
    required String category,
    double baseSize = 200.0,
  }) {
    final smallSide = math.min(screenSize.width, screenSize.height);
    double targetSize = smallSide * 0.4; // 40% of short side by default

    switch (category) {
      case 'Home':
        targetSize = smallSide * 0.55;
        break;
      case 'Electronics':
        targetSize = smallSide * 0.42;
        break;
      case 'Accessories':
        targetSize = smallSide * 0.28;
        break;
    }
    return targetSize / baseSize;
  }

  // ── Perspective / Matrix ──────────────────────────────────────────────────

  /// Applies a subtle perspective tilt transform based on device gyroscope data.
  static Matrix4 applyPerspectiveTilt({
    required double tiltX,
    required double tiltY,
    double depth = 0.001,
    double maxAngle = 0.25,
  }) {
    final rx = (tiltY * maxAngle).clamp(-maxAngle, maxAngle);
    final ry = (tiltX * maxAngle).clamp(-maxAngle, maxAngle);

    return Matrix4.identity()
      ..setEntry(3, 2, depth)
      ..rotateX(rx)
      ..rotateY(ry);
  }

  // ── Shadow ────────────────────────────────────────────────────────────────

  /// Computes an elliptical shadow Rect positioned below a product.
  static Rect computeShadowRect(Rect productRect, double shadowScale) {
    final centerX = productRect.center.dx;
    final bottom = productRect.bottom;
    final shadowWidth = productRect.width * shadowScale;
    final shadowHeight = shadowWidth * 0.25;
    return Rect.fromCenter(
      center: Offset(centerX, bottom + shadowHeight * 0.3),
      width: shadowWidth,
      height: shadowHeight,
    );
  }

  /// Paints an elliptical drop shadow beneath the product.
  static void paintShadow(
    Canvas canvas,
    Rect shadowRect, {
    double opacity = 0.3,
    double blurRadius = 24.0,
  }) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);
    canvas.drawOval(shadowRect, paint);
  }

  // ── AR Grid / Guide ───────────────────────────────────────────────────────

  /// Draws a grid of guide lines on the canvas (simulates AR floor plane detection).
  static void paintGuideGrid(
    Canvas canvas,
    Size size, {
    int columns = 6,
    int rows = 8,
    double opacity = 0.18,
    Color color = Colors.white,
  }) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    // Perspective grid — lines converge toward vanishing point at top center
    final vpX = size.width / 2;
    final vpY = size.height * 0.45; // vanishing point

    // Horizontal lines (evenly spaced in bottom half)
    for (int i = 0; i <= rows; i++) {
      final t = i / rows;
      final y = vpY + (size.height - vpY) * t;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical lines converging to vanishing point
    for (int i = 0; i <= columns; i++) {
      final t = i / columns;
      final bottomX = size.width * t;
      canvas.drawLine(Offset(vpX, vpY), Offset(bottomX, size.height), paint);
    }
  }

  /// Draws a scanning sweep line animation at position [progress] (0.0 - 1.0).
  static void paintScanLine(Canvas canvas, Size size, double progress, {Color color = const Color(0xFF00C8FF)}) {
    final y = size.height * progress;
    final gradient = LinearGradient(
      colors: [
        color.withValues(alpha: 0.0),
        color.withValues(alpha: 0.8),
        color.withValues(alpha: 0.0),
      ],
    );
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, y - 4, size.width, 8))
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  // ── Glow Effect ───────────────────────────────────────────────────────────

  /// Paints a neon glow border around the given rect (for selected products).
  static void paintGlowBorder(
    Canvas canvas,
    Rect rect, {
    required Color color,
    double glowRadius = 12.0,
    double borderRadius = 16.0,
    double opacity = 0.6,
  }) {
    final rRect = RRect.fromRectAndRadius(rect.inflate(4), Radius.circular(borderRadius));
    for (int i = 3; i >= 1; i--) {
      final paint = Paint()
        ..color = color.withValues(alpha: opacity / i)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius * i * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRRect(rRect, paint);
    }
    // Solid inner border
    final solidPaint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rRect, solidPaint);
  }

  // ── Format helpers ────────────────────────────────────────────────────────

  static String formatARHint(String category) {
    switch (category) {
      case 'Home':
        return 'Point at a flat surface to place';
      case 'Electronics':
        return 'Drag to position on any surface';
      case 'Fashion':
        return 'Switch to front camera to try on';
      case 'Accessories':
        return 'Move to your wrist or face area';
      default:
        return 'Drag & pinch to position the product';
    }
  }
}
