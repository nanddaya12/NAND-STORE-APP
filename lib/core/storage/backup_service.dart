import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'hive_service.dart';

class BackupService {
  static final BackupService instance = BackupService._internal();
  BackupService._internal();

  // Export selected boxes data to a JSON backup file
  Future<String> exportBackup() async {
    final Map<String, dynamic> backupData = {};
    final boxesToBackup = ['settings', 'wishlist', 'cart', 'search_history'];

    for (final boxName in boxesToBackup) {
      final box = HiveService.instance.getBox(boxName);
      final Map<String, dynamic> boxData = {};
      
      for (final key in box.keys) {
        boxData[key.toString()] = box.get(key);
      }
      backupData[boxName] = boxData;
    }

    final jsonString = jsonEncode(backupData);
    
    // Save to local directory file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/nand_store_backup.json');
    await file.writeAsString(jsonString);
    
    return file.path;
  }
}
