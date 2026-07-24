import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class SyncItem {
  final String id;
  final String path;
  final String method; // 'POST', 'PUT', 'DELETE'
  final Map<String, dynamic> payload;

  SyncItem({
    required this.id,
    required this.path,
    required this.method,
    required this.payload,
  });
}

class SyncQueue {
  final List<SyncItem> _queue = [];
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _subscription;
  bool _isSyncing = false;

  static final SyncQueue instance = SyncQueue._internal();
  SyncQueue._internal() {
    _startListening();
  }

  void _startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        syncPendingItems();
      }
    });
  }

  void enqueue(String path, String method, Map<String, dynamic> payload) {
    final item = SyncItem(
      id: 'sync-${DateTime.now().millisecondsSinceEpoch}',
      path: path,
      method: method,
      payload: payload,
    );
    _queue.add(item);
  }

  Future<void> syncPendingItems() async {
    if (_isSyncing || _queue.isEmpty) return;
    _isSyncing = true;

    // Process queued operations
    final List<SyncItem> processed = [];
    for (var item in _queue) {
      try {
        // Mock successful background sync upload call
        await Future.delayed(const Duration(milliseconds: 600));
        processed.add(item);
      } catch (e) {
        // Sync failed, keep in queue and stop processing
        break;
      }
    }

    _queue.removeWhere((item) => processed.contains(item));
    _isSyncing = false;
  }

  void dispose() {
    _subscription?.cancel();
  }
}
