import 'preferences_service.dart';
import 'secure_storage_service.dart';
import 'hive_service.dart';
import 'migration_manager.dart';

class Database {
  static final Database instance = Database._internal();
  Database._internal();

  Future<void> init() async {
    // 1. Initialize SharedPreferences configurations
    await PreferencesService.instance.init();

    // 2. Initialize Hive Service boxes & AES encryption setups
    await HiveService.instance.init();

    // 3. Perform database schema migration checks
    await MigrationManager.instance.performMigrationChecks();

    // 4. Compact database files
    await HiveService.instance.compactAllBoxes();
  }

  // Helper method to clear all cached storage on user logout
  Future<void> clearAllSessionData() async {
    await HiveService.instance.clearAllBoxes();
    await SecureStorageService.instance.clear();
  }
}
