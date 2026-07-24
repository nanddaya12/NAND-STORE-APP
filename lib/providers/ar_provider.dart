import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../features/catalog/domain/entities/product.dart';

enum ARMode { placeInRoom, tryOn, compare }

class ARProductState {
  final Product product;
  Offset position;
  double scale;
  double rotation;
  bool isSelected;

  ARProductState({
    required this.product,
    this.position = const Offset(0.5, 0.5), // normalized 0-1
    this.scale = 1.0,
    this.rotation = 0.0,
    this.isSelected = false,
  });

  ARProductState copyWith({
    Offset? position,
    double? scale,
    double? rotation,
    bool? isSelected,
  }) {
    return ARProductState(
      product: product,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class ARProvider extends ChangeNotifier {
  ARMode _mode = ARMode.placeInRoom;
  bool _isCameraReady = false;
  bool _isCameraPermissionGranted = false;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  bool _showGuideLines = true;
  bool _shadowEnabled = true;
  String? _snapshotPath;
  final List<String> _snapshots = [];
  final List<ARProductState> _arProducts = [];
  int _selectedProductIndex = -1;

  // Tilt/gyroscope effect
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  // Parallax depth multiplier
  double _parallaxDepth = 0.015;

  // Getters
  ARMode get mode => _mode;
  bool get isCameraReady => _isCameraReady;
  bool get isCameraPermissionGranted => _isCameraPermissionGranted;
  bool get isFlashOn => _isFlashOn;
  bool get isFrontCamera => _isFrontCamera;
  bool get showGuideLines => _showGuideLines;
  bool get shadowEnabled => _shadowEnabled;
  String? get snapshotPath => _snapshotPath;
  List<String> get snapshots => List.unmodifiable(_snapshots);
  List<ARProductState> get arProducts => List.unmodifiable(_arProducts);
  int get selectedProductIndex => _selectedProductIndex;
  double get tiltX => _tiltX;
  double get tiltY => _tiltY;
  double get parallaxDepth => _parallaxDepth;

  ARProductState? get selectedProduct =>
      _selectedProductIndex >= 0 && _selectedProductIndex < _arProducts.length
          ? _arProducts[_selectedProductIndex]
          : null;

  // ── Camera Lifecycle ──────────────────────────────────────────────────────

  void setCameraPermissionGranted(bool granted) {
    _isCameraPermissionGranted = granted;
    notifyListeners();
  }

  void setCameraReady(bool ready) {
    _isCameraReady = ready;
    notifyListeners();
  }

  void toggleFlash() {
    _isFlashOn = !_isFlashOn;
    notifyListeners();
  }

  void toggleCamera() {
    _isFrontCamera = !_isFrontCamera;
    notifyListeners();
  }

  // ── AR Mode ───────────────────────────────────────────────────────────────

  void setMode(ARMode mode) {
    _mode = mode;
    notifyListeners();
  }

  // ── Product Management ────────────────────────────────────────────────────

  void addProduct(Product product, Size screenSize) {
    // Place at center by default
    final state = ARProductState(
      product: product,
      position: const Offset(0.5, 0.5),
      scale: _computeInitialScale(product, screenSize),
    );
    _arProducts.add(state);
    _selectedProductIndex = _arProducts.length - 1;
    notifyListeners();
  }

  double _computeInitialScale(Product product, Size screenSize) {
    // Furniture/Home items appear larger, accessories smaller
    switch (product.category) {
      case 'Home':
        return 1.4;
      case 'Electronics':
        return 1.1;
      case 'Fashion':
        return 1.0;
      case 'Accessories':
        return 0.7;
      default:
        return 1.0;
    }
  }

  void removeProduct(int index) {
    if (index >= 0 && index < _arProducts.length) {
      _arProducts.removeAt(index);
      if (_selectedProductIndex >= _arProducts.length) {
        _selectedProductIndex = _arProducts.length - 1;
      }
      notifyListeners();
    }
  }

  void clearAllProducts() {
    _arProducts.clear();
    _selectedProductIndex = -1;
    notifyListeners();
  }

  void selectProduct(int index) {
    _selectedProductIndex = index;
    for (var i = 0; i < _arProducts.length; i++) {
      _arProducts[i] = _arProducts[i].copyWith(isSelected: i == index);
    }
    notifyListeners();
  }

  // ── Product Transform ─────────────────────────────────────────────────────

  void updateProductPosition(int index, Offset delta, Size screenSize) {
    if (index < 0 || index >= _arProducts.length) return;
    final current = _arProducts[index];
    final newX = (current.position.dx + delta.dx / screenSize.width).clamp(0.05, 0.95);
    final newY = (current.position.dy + delta.dy / screenSize.height).clamp(0.05, 0.95);
    _arProducts[index] = current.copyWith(position: Offset(newX, newY));
    notifyListeners();
  }

  void updateProductScale(int index, double scaleFactor) {
    if (index < 0 || index >= _arProducts.length) return;
    final current = _arProducts[index];
    final newScale = (current.scale * scaleFactor).clamp(0.3, 4.0);
    _arProducts[index] = current.copyWith(scale: newScale);
    notifyListeners();
  }

  void updateProductRotation(int index, double angleDelta) {
    if (index < 0 || index >= _arProducts.length) return;
    final current = _arProducts[index];
    _arProducts[index] = current.copyWith(rotation: current.rotation + angleDelta);
    notifyListeners();
  }

  void resetProductTransform(int index) {
    if (index < 0 || index >= _arProducts.length) return;
    final current = _arProducts[index];
    _arProducts[index] = ARProductState(
      product: current.product,
      position: const Offset(0.5, 0.5),
      scale: 1.0,
      rotation: 0.0,
    );
    notifyListeners();
  }

  // ── Gyroscope / Tilt ──────────────────────────────────────────────────────

  void updateTilt(double x, double y) {
    // Smooth the tilt with lerp
    _tiltX = _tiltX * 0.85 + x * 0.15;
    _tiltY = _tiltY * 0.85 + y * 0.15;
    // Clamp
    _tiltX = _tiltX.clamp(-1.0, 1.0);
    _tiltY = _tiltY.clamp(-1.0, 1.0);
    notifyListeners();
  }

  // ── Settings ──────────────────────────────────────────────────────────────

  void toggleGuideLines() {
    _showGuideLines = !_showGuideLines;
    notifyListeners();
  }

  void toggleShadow() {
    _shadowEnabled = !_shadowEnabled;
    notifyListeners();
  }

  void setParallaxDepth(double depth) {
    _parallaxDepth = depth.clamp(0.0, 0.05);
    notifyListeners();
  }

  // ── Snapshot ──────────────────────────────────────────────────────────────

  void addSnapshot(String path) {
    _snapshots.add(path);
    _snapshotPath = path;
    notifyListeners();
  }

  // ── Randomized "AR scan" animation helper ─────────────────────────────────

  /// Returns a list of scan line positions (0.0 - 1.0) for the scanning animation
  List<double> getScanLines(int count) {
    final rng = math.Random(42);
    return List.generate(count, (_) => rng.nextDouble());
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  void resetSession() {
    _arProducts.clear();
    _selectedProductIndex = -1;
    _tiltX = 0.0;
    _tiltY = 0.0;
    _isFlashOn = false;
    _snapshotPath = null;
    notifyListeners();
  }
}
