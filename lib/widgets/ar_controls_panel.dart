import 'package:flutter/material.dart';
import '../providers/ar_provider.dart';
import '../core/utils/ar_utils.dart';
import '../models/store_models.dart';

/// Floating HUD controls panel for the AR view.
/// Shows mode toggle, action buttons, and product variant switcher.
class ARControlsPanel extends StatefulWidget {
  final ARProvider arProvider;
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onSnapshot;
  final VoidCallback onReset;
  final VoidCallback onClose;
  final bool isCompact;

  const ARControlsPanel({
    super.key,
    required this.arProvider,
    required this.product,
    required this.onAddToCart,
    required this.onSnapshot,
    required this.onReset,
    required this.onClose,
    this.isCompact = false,
  });

  @override
  State<ARControlsPanel> createState() => _ARControlsPanelState();
}

class _ARControlsPanelState extends State<ARControlsPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  bool _showModePanel = false;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = ARUtils.categoryARColor(widget.product.category);
    final hint = ARUtils.formatARHint(widget.product.category);

    return SlideTransition(
      position: _slideAnim,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hint text
          if (!widget.isCompact)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app, color: categoryColor, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      hint,
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),

          // Quick action row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildIconBtn(
                  icon: Icons.refresh,
                  label: 'Reset',
                  color: Colors.white,
                  onTap: widget.onReset,
                ),
                const SizedBox(width: 8),
                _buildIconBtn(
                  icon: widget.arProvider.showGuideLines ? Icons.grid_on : Icons.grid_off,
                  label: 'Grid',
                  color: widget.arProvider.showGuideLines ? categoryColor : Colors.white54,
                  onTap: () => widget.arProvider.toggleGuideLines(),
                ),
                const SizedBox(width: 8),
                _buildIconBtn(
                  icon: widget.arProvider.shadowEnabled ? Icons.blur_on : Icons.blur_off,
                  label: 'Shadow',
                  color: widget.arProvider.shadowEnabled ? categoryColor : Colors.white54,
                  onTap: () => widget.arProvider.toggleShadow(),
                ),
                const SizedBox(width: 8),
                _buildIconBtn(
                  icon: Icons.camera_alt_outlined,
                  label: 'Snap',
                  color: Colors.white,
                  onTap: widget.onSnapshot,
                ),
                const Spacer(),
                // Mode toggle button
                GestureDetector(
                  onTap: () => setState(() => _showModePanel = !_showModePanel),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        Icon(_modeIcon(widget.arProvider.mode), color: categoryColor, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          _modeLabel(widget.arProvider.mode),
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _showModePanel ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                          color: Colors.white54,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Mode selection panel (slide up)
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: _showModePanel ? _buildModePanel(categoryColor) : const SizedBox.shrink(),
          ),

          // Bottom main action area
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Product info row
                Row(
                  children: [
                    // Product thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: widget.product.images.isNotEmpty
                          ? Image.network(
                              widget.product.images.first,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, _) => Container(
                                width: 48,
                                height: 48,
                                color: const Color(0xFF1A1A2E),
                                child: Icon(
                                  ARUtils.categoryARIcon(widget.product.category),
                                  color: categoryColor,
                                  size: 24,
                                ),
                              ),
                            )
                          : Container(
                              width: 48,
                              height: 48,
                              color: const Color(0xFF1A1A2E),
                              child: Icon(
                                ARUtils.categoryARIcon(widget.product.category),
                                color: categoryColor,
                                size: 24,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '\$${widget.product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: categoryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Rating chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7F5700).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFFFB62C), size: 12),
                          const SizedBox(width: 3),
                          Text(
                            '${widget.product.rating}',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Add to Cart CTA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: categoryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: widget.onAddToCart,
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: const Text(
                      'Add to Cart',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModePanel(Color categoryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            _buildModeChip(ARMode.placeInRoom, Icons.weekend, 'Place', categoryColor),
            const SizedBox(width: 8),
            _buildModeChip(ARMode.tryOn, Icons.face, 'Try On', categoryColor),
            const SizedBox(width: 8),
            _buildModeChip(ARMode.compare, Icons.compare, 'Compare', categoryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildModeChip(ARMode mode, IconData icon, String label, Color activeColor) {
    final isSelected = widget.arProvider.mode == mode;
    final isEnabled = mode == ARMode.tryOn
        ? ARUtils.categorySupportsARTryOn(widget.product.category)
        : true;

    return Expanded(
      child: GestureDetector(
        onTap: isEnabled
            ? () {
                widget.arProvider.setMode(mode);
                setState(() => _showModePanel = false);
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : Colors.white12,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? activeColor : (isEnabled ? Colors.white54 : Colors.white24),
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? activeColor : (isEnabled ? Colors.white70 : Colors.white30),
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (!isEnabled)
                const Text(
                  'Fashion only',
                  style: TextStyle(color: Colors.white24, fontSize: 8),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 9),
          ),
        ],
      ),
    );
  }

  IconData _modeIcon(ARMode mode) {
    switch (mode) {
      case ARMode.placeInRoom:
        return Icons.weekend;
      case ARMode.tryOn:
        return Icons.face;
      case ARMode.compare:
        return Icons.compare;
    }
  }

  String _modeLabel(ARMode mode) {
    switch (mode) {
      case ARMode.placeInRoom:
        return 'Place';
      case ARMode.tryOn:
        return 'Try On';
      case ARMode.compare:
        return 'Compare';
    }
  }
}
