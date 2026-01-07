/// Firestore Seed Service
///
/// Populates Firestore with sample genres and songs for testing.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'hive_storage_service.dart';

class FirestoreSeedService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedIfEmpty() async {
    // Check if genres collection already has data
    final genresSnapshot = await _firestore.collection('genres').limit(1).get();

    if (genresSnapshot.docs.isNotEmpty) {
      print('Firestore already has data, skipping seed');
      // But still seed liked songs if empty
      await _seedLikedSongs();
      return;
    }

    print('Seeding Firestore with sample data...');

    try {
      // Add genres
      await _addGenres();

      // Add songs
      await _addSongs();

      // Add feed items
      await _addFeedItems();

      print('Firestore seed completed successfully');
    } catch (e) {
      print('Error seeding Firestore: $e');
    }
  }

  static Future<void> _addGenres() async {
    final genres = [
      {
        'id': 'rock',
        'name': 'Rock',
        'coverUrl': 'http://placeholder.com/400x400?text=Rock',
        'order': 1,
      },
      {
        'id': 'pop',
        'name': 'Pop',
        'coverUrl': 'http://placeholder.com/400x400?text=Pop',
        'order': 2,
      },
      {
        'id': 'jazz',
        'name': 'Jazz',
        'coverUrl': 'http://placeholder.com/400x400?text=Jazz',
        'order': 3,
      },
      {
        'id': 'classical',
        'name': 'Classical',
        'coverUrl': 'http://placeholder.com/400x400?text=Classical',
        'order': 4,
      },
    ];

    final genresRef = _firestore.collection('genres');
    for (final genre in genres) {
      await genresRef.doc(genre['id'] as String).set(genre);
    }
    print('Added ${genres.length} genres');
  }

  static Future<void> _addSongs() async {
    final now = DateTime.now();
    final songs = [
      {
        'id': 'song_midnight_dreams',
        'title': 'Midnight Dreams',
        'artist': 'The Dreamers',
        'genre': 'Rock',
        'genreId': 'rock',
        'coverUrl': 'http://placeholder.com/300x300?text=Midnight',
        'duration': 240,
        'is_active': true,
        'created_at': now.subtract(const Duration(days: 5)).toIso8601String(),
      },
      {
        'id': 'song_electric_vibes',
        'title': 'Electric Vibes',
        'artist': 'Neon Lights',
        'genre': 'Pop',
        'genreId': 'pop',
        'coverUrl': 'http://placeholder.com/300x300?text=Electric',
        'duration': 200,
        'is_active': true,
        'created_at': now.subtract(const Duration(days: 4)).toIso8601String(),
      },
      {
        'id': 'song_smooth_jazz',
        'title': 'Smooth Jazz Evening',
        'artist': 'Jazz Quartet',
        'genre': 'Jazz',
        'genreId': 'jazz',
        'coverUrl': 'http://placeholder.com/300x300?text=Jazz',
        'duration': 320,
        'is_active': true,
        'created_at': now.subtract(const Duration(days: 3)).toIso8601String(),
      },
      {
        'id': 'song_symphony',
        'title': 'Symphony No.5',
        'artist': 'Classical Orchestra',
        'genre': 'Classical',
        'genreId': 'classical',
        'coverUrl': 'http://placeholder.com/300x300?text=Symphony',
        'duration': 600,
        'is_active': true,
        'created_at': now.subtract(const Duration(days: 2)).toIso8601String(),
      },
      {
        'id': 'song_summer_nights',
        'title': 'Summer Nights',
        'artist': 'Beach Boys',
        'genre': 'Pop',
        'genreId': 'pop',
        'coverUrl': 'http://placeholder.com/300x300?text=Summer',
        'duration': 210,
        'is_active': true,
        'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'id': 'song_hard_rock',
        'title': 'Hard Rock Anthem',
        'artist': 'Thunder Road',
        'genre': 'Rock',
        'genreId': 'rock',
        'coverUrl': 'http://placeholder.com/300x300?text=Rock',
        'duration': 280,
        'is_active': true,
        'created_at': now.toIso8601String(),
      },
    ];

    final songsRef = _firestore.collection('songs');
    for (final song in songs) {
      await songsRef.doc(song['id'] as String).set(song);
    }
    print('Added ${songs.length} songs');

    // Auto-populate some songs as liked for demo
    await _seedLikedSongs();
  }

  static Future<void> _addFeedItems() async {
    final feedItems = [
      {
        'songId': 'song_midnight_dreams',
        'title': 'Midnight Dreams',
        'artist': 'The Dreamers',
        'genre': 'Rock',
        'coverUrl': 'http://placeholder.com/300x300?text=Midnight',
        'timestamp': FieldValue.serverTimestamp(),
      },
      {
        'songId': 'song_electric_vibes',
        'title': 'Electric Vibes',
        'artist': 'Neon Lights',
        'genre': 'Pop',
        'coverUrl': 'http://placeholder.com/300x300?text=Electric',
        'timestamp': FieldValue.serverTimestamp(),
      },
      {
        'songId': 'song_smooth_jazz',
        'title': 'Smooth Jazz Evening',
        'artist': 'Jazz Quartet',
        'genre': 'Jazz',
        'coverUrl': 'http://placeholder.com/300x300?text=Jazz',
        'timestamp': FieldValue.serverTimestamp(),
      },
    ];

    final feedRef = _firestore.collection('feed');
    for (final item in feedItems) {
      await feedRef.add(item);
    }
    print('Added ${feedItems.length} feed items');
  }

  static Future<void> _seedLikedSongs() async {
    // Add a few songs as liked for demo purposes
    final likedSongIds = [
      'song_midnight_dreams',
      'song_electric_vibes',
      'song_smooth_jazz',
    ];

    // Store in Hive locally
    await HiveStorageService.instance.seedLikedSongIds(likedSongIds);
    print('Seeded ${likedSongIds.length} liked songs');
  }
}
