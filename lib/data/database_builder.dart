import 'package:flutter/services.dart';
import 'dart:convert';
import 'database_helper.dart';

class DatabaseBuilder {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Build the complete database from assets/songs.json
  Future<void> buildDatabase() async {
    print('🎵 Building music database from songs.json...');

    // Clear existing data to ensure a clean rebuild
    await _db.clearAllTables();

    // Load and parse JSON file
    final jsonString = await rootBundle.loadString('assets/songs.json');
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;

    final playlistsJson = (jsonData['playlists'] as List?) ?? [];
    final songsJson = (jsonData['songs'] as List?) ?? [];

    // 1. Create playlists from JSON
    await _createPlaylistsFromJson(playlistsJson);

    // 2. Add songs (and lyrics) from JSON
    await _addSongsFromJson(songsJson);

    print('✅ Database built successfully!');
  }

  Future<void> _createPlaylistsFromJson(List playlistsJson) async {
    for (final playlist in playlistsJson) {
      final map = Map<String, dynamic>.from(playlist as Map);
      await _db.insertPlaylist({
        'id': map['id'],
        'name': map['name'],
        'description': map['description'],
        'coverImage': map['coverImage'],
      });
    }
  }

  Future<void> _addSongsFromJson(List songsJson) async {
    for (final song in songsJson) {
      final map = Map<String, dynamic>.from(song as Map);
      final songId = await _db.insertSong({
        'title': map['title'],
        'artist': map['artist'],
        'album': map['album'],
        'duration': map['duration'],
        'audioPath': map['audioPath'],
        // Prefer per-track art (songImage) and fall back to albumArt if present
        'albumArt': map['songImage'] ?? map['albumArt'],
        'genre': map['genre'],
        'year': map['year'],
        'playlistId': map['playlistId'],
      });

      final lyricsText = (map['lyrics'] as String?)?.trim();
      if (lyricsText != null && lyricsText.isNotEmpty) {
        await _db.insertLyrics({
          'songId': songId,
          'text': lyricsText,
          'language': 'en',
          'isTimeSynced': (map['isTimeSynced'] as bool? ?? false) ? 1 : 0,
        });
      }
    }
  }

  Future<void> addSong({
    required String title,
    required String artist,
    required String album,
    required String duration,
    required String audioPath,
    required String albumArt,
    required String genre,
    required String playlistId,
    required String lyricsText,
    required bool isTimeSynced,
  }) async {
    final songId = await _db.insertSong({
      'title': title,
      'artist': artist,
      'album': album,
      'duration': duration,
      'audioPath': audioPath,
      'albumArt': albumArt,
      'genre': genre,
      'playlistId': playlistId,
    });

    if (lyricsText.isNotEmpty) {
      await _db.insertLyrics({
        'songId': songId,
        'text': lyricsText,
        'isTimeSynced': isTimeSynced ? 1 : 0,
        'language': 'en',
      });
    }
  }
}
