/// Firestore Configuration Service
///
/// Configures Firestore settings including offline persistence.

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreConfig {
  static Future<void> initialize() async {
    final firestore = FirebaseFirestore.instance;

    // Enable offline persistence for better performance and caching
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
}
