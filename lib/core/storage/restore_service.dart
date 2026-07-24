import 'dart:convert';
import 'dart:io';
import 'hive_service.dart';

class RestoreService {
  static final RestoreService instance = RestoreService._internal();
  RestoreService._internal();

  // Import and restore boxes data from a JSON backup file
  Future<bool> restoreBackup(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return false;

    try {
      final jsonString = await file.readAsString();
      final Map<String, dynamic> backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      for (final boxName in backupData.keys) {
        final box = HiveService.instance.getBox(boxName);
        final Map<String, dynamic> boxData = Map<String, dynamic>.from(backupData[boxName] as Map);
        
        // Write backup values into box
        for (final key in boxData.keys) {
          await box.put(key, boxData[key]);
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
