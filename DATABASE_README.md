# Database README

Quick start documentation for the storage mechanisms of the **NAND Store** project.

## 1. Quick Initialization on App Boot

To initialize preferences, open Hive boxes, verify migrations, and run compaction, execute:
```dart
await Database.instance.init();
```
All details are orchestrated inside `lib/main.dart` in `main()`.

## 2. Reading and Writing to SharedPreferences

Use the plain-text options wrapper:
```dart
final theme = PreferencesService.instance.getThemeMode();
await PreferencesService.instance.setThemeMode('dark');
```

## 3. Reading and Writing to Encrypted Secure Storage

Use the secure key-value wrapper for credentials:
```dart
await SecureStorageService.instance.write('access_token', 'jwt_payload_here');
final token = await SecureStorageService.instance.read('access_token');
```

## 4. Querying and Manipulating Hive Cache

Use the Hive Service interface to query specific boxes:
```dart
final cartBox = HiveService.instance.getBox('cart');
await cartBox.put('p1', {'quantity': 1});
```

## 5. Exporting / Restoring Local Backups

Create a JSON database backup:
```dart
final backupPath = await BackupService.instance.exportBackup();
```
Restore details from a file:
```dart
bool success = await RestoreService.instance.restoreBackup(backupPath);
```
