/// Genre Remote Data Source
///
/// Fetches genre data from Firestore (read-only).

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/genre_model_firestore.dart';

class GenreRemoteDataSource {
  final FirebaseFirestore _firestore;

  GenreRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetch all genres ordered by 'order' field
  Future<List<GenreModel>> getGenresOrdered() async {
    try {
      final snapshot = await _firestore
          .collection('genres')
          .orderBy('order')
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Add the document ID as the genre ID
        return GenreModel.fromJson({'id': doc.id, ...data});
      }).toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch genres: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch genres: $e');
    }
  }
}
