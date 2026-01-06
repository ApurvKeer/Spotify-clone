/// Feed Remote Data Source
///
/// Fetches feed items from Firestore and resolves them to songs (read-only).

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feed_item_model.dart';
import '../models/song_model_firestore.dart';
import 'song_remote_datasource.dart';

class FeedRemoteDataSource {
  final FirebaseFirestore _firestore;
  final SongRemoteDataSource _songDataSource;

  FeedRemoteDataSource({
    FirebaseFirestore? firestore,
    required SongRemoteDataSource songDataSource,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _songDataSource = songDataSource;

  /// Fetch feed songs ordered by priority
  /// Returns resolved Song objects, not just feed items
  Future<List<SongModel>> getFeedSongs() async {
    try {
      // Fetch feed items ordered by priority (higher first)
      final feedSnapshot = await _firestore
          .collection('feed')
          .orderBy('priority', descending: true)
          .get();

      if (feedSnapshot.docs.isEmpty) {
        return [];
      }

      final feedItems = feedSnapshot.docs.map((doc) {
        return FeedItemModel.fromJson(doc.data());
      }).toList();

      // Fetch corresponding songs
      final songs = <SongModel>[];
      for (final item in feedItems) {
        try {
          final song = await _songDataSource.getSongById(item.songId);
          if (song != null) {
            songs.add(song);
          }
        } catch (e) {
          // Log but don't crash if a single song fails
          // In production, use a proper logger
          print('Warning: Failed to fetch song ${item.songId} for feed: $e');
        }
      }

      return songs;
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch feed: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch feed: $e');
    }
  }
}
