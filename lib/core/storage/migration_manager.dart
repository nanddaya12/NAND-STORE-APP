import 'preferences_service.dart';
import 'package:hive/hive.dart';

class MigrationManager {
  static const int currentSchemaVersion = 2;

  static final MigrationManager instance = MigrationManager._internal();
  MigrationManager._internal();

  Future<void> performMigrationChecks() async {
    final prefs = PreferencesService.instance;
    final int oldVersion = prefs.getInt('db_schema_version', defaultValue: 1);

    if (oldVersion < currentSchemaVersion) {
      await _runMigrations(oldVersion, currentSchemaVersion);
      await prefs.setInt('db_schema_version', currentSchemaVersion);
    }
  }

  Future<void> _runMigrations(int fromVersion, int toVersion) async {
    // Sequence migrations
    for (int version = fromVersion; version < toVersion; version++) {
      if (version == 1) {
        await _migrateV1ToV2();
      }
      // Future versions go here:
      // if (version == 2) { await _migrateV2ToV3(); }
    }
  }

  Future<void> _migrateV1ToV2() async {
    // Migration v1 to v2: example renaming, mapping, or formatting old data box records.
    try {
      final cartBox = await Hive.openBox('cart');
      // Verify if old keys need format conversions or migrations
      for (var key in cartBox.keys) {
        final val = cartBox.get(key);
        if (val is Map) {
          // Schema enhancement transformation
          final updated = Map<String, dynamic>.from(val);
          updated['migrated_at'] = DateTime.now().toIso8601String();
          updated['version'] = 2;
          await cartBox.put(key, updated);
        }
      }
    } catch (e) {
      // If box is corrupted during opening or migration, clear to prevent crashes.
      await Hive.deleteBoxFromDisk('cart');
    }
  }
}
