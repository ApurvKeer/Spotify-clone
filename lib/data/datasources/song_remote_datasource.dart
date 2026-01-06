/// Song Remote Data Source
///
/// Fetches song data from Firestore (read-only).

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song_model_firestore.dart';

class SongRemoteDataSource {
  final FirebaseFirestore _firestore;

  SongRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetch songs by genre (only active songs)
  Future<List<SongModel>> getSongsByGenre(String genre) async {
    try {
      final snapshot = await _firestore
          .collection('songs')
          .where('genre', isEqualTo: genre)
          .where('is_active', isEqualTo: true)
          .orderBy('created_at', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Add the document ID as the song ID
        return SongModel.fromJson({'id': doc.id, ...data});
      }).toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch songs by genre: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch songs by genre: $e');
    }
  }

  /// Fetch a single song by ID
  Future<SongModel?> getSongById(String id) async {
    try {
      final doc = await _firestore.collection('songs').doc(id).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data();
      if (data == null) {
        return null;
      }

      // Check if song is active
      if (data['is_active'] != true) {
        return null;
      }

      return SongModel.fromJson({'id': doc.id, ...data});
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch song by ID: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch song by ID: $e');
    }
  }

  /// Fetch all active songs (for internal use, e.g., feed resolution)
  Future<List<SongModel>> getAllActiveSongs() async {
    try {
      final snapshot = await _firestore
          .collection('songs')
          .where('is_active', isEqualTo: true)
          .orderBy('created_at', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SongModel.fromJson({'id': doc.id, ...data});
      }).toList();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch all songs: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch all songs: $e');
    }
  }
}
