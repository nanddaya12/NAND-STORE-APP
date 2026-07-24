import 'package:hive_flutter/hive_flutter.dart';
import 'secure_storage_service.dart';

class HiveService {
  static final HiveService instance = HiveService._internal();
  HiveService._internal();

  // Reference lists of open boxes
  final List<String> _plainBoxes = [
    'products',
    'categories',
    'wishlist',
    'notifications',
    'search_history',
    'recent_products',
    'settings',
    'app_cache',
  ];

  final List<String> _encryptedBoxes = [
    'users',
    'orders',
    'cart',
  ];

  Future<void> init() async {
    await Hive.initFlutter();
    
    // Fetch AES encryption key for securing data
    final encryptionKey = await SecureStorageService.instance.getHiveEncryptionKey();
    
    // Open plain boxes
    for (final boxName in _plainBoxes) {
      await Hive.openBox(boxName);
    }

    // Open encrypted boxes using AES Cipher block
    for (final boxName in _encryptedBoxes) {
      await Hive.openBox(
        boxName,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );
    }
  }

  // Get a box
  Box getBox(String boxName) => Hive.box(boxName);

  // Compact all open boxes to save memory/disk space
  Future<void> compactAllBoxes() async {
    for (final boxName in [..._plainBoxes, ..._encryptedBoxes]) {
      final box = Hive.box(boxName);
      if (box.isOpen) {
        await box.compact();
      }
    }
  }

  // Clear all databases
  Future<void> clearAllBoxes() async {
    for (final boxName in [..._plainBoxes, ..._encryptedBoxes]) {
      final box = Hive.box(boxName);
      if (box.isOpen) {
        await box.clear();
      }
    }
  }
}
