import 'package:flutter/services.dart' show rootBundle;
import 'database_helper.dart';
import 'song.dart';
import 'lyrics.dart';

/// Helper class to seed the database with initial data
class DatabaseSeeder {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Seed the database with sample songs and lyrics
  Future<void> seedDatabase() async {
    // Check if database is already seeded
    final existingSongs = await _dbHelper.getSongs();
    if (existingSongs.isNotEmpty) {
      print('Database already contains data. Skipping seed.');
      return;
    }

    print('Seeding database...');

    // Create playlists
    await _createPlaylists();

    // Import songs from CSV files
    await _importSongsFromCSV('assets/playlists/lofi.csv', 'lofi');
    await _importSongsFromCSV('assets/playlists/pop.csv', 'pop');
    await _importSongsFromCSV('assets/playlists/synthwave.csv', 'synthwave');

    // Add sample lyrics
    await _addSampleLyrics();

    print('Database seeding completed!');
  }

  Future<void> _createPlaylists() async {
    final playlists = [
      const Playlist(
        id: 'lofi',
        name: 'Lo-Fi Beats',
        description: 'Chill lo-fi music for studying and relaxation',
      ),
      const Playlist(
        id: 'pop',
        name: 'Pop Hits',
        description: 'Latest pop music hits',
      ),
      const Playlist(
        id: 'synthwave',
        name: 'Synthwave',
        description: 'Retro synthwave vibes',
      ),
    ];

    for (final playlist in playlists) {
      await _dbHelper.insertPlaylist(playlist.toMap());
    }
  }

  Future<void> _importSongsFromCSV(
    String csvAssetPath,
    String playlistId,
  ) async {
    try {
      final raw = await rootBundle.loadString(csvAssetPath);
      final lines = raw.split('\n').where((l) => l.trim().isNotEmpty).toList();

      if (lines.isNotEmpty) {
        lines.removeAt(0); // remove header
      }

      for (final line in lines) {
        final parts = line.split(',');
        if (parts.length >= 3) {
          final song = Song(
            title: parts[0].trim(),
            artist: parts[1].trim(),
            duration: parts[2].trim(),
            playlistId: playlistId,
            genre: _getGenreForPlaylist(playlistId),
          );
          await _dbHelper.insertSong(song.toMap());
        }
      }

      print('Imported songs from $csvAssetPath');
    } catch (e) {
      print('Error importing $csvAssetPath: $e');
    }
  }

  String _getGenreForPlaylist(String playlistId) {
    switch (playlistId) {
      case 'lofi':
        return 'Lo-Fi';
      case 'pop':
        return 'Pop';
      case 'synthwave':
        return 'Synthwave';
      default:
        return 'Unknown';
    }
  }

  Future<void> _addSampleLyrics() async {
    // Add sample lyrics for the first song in each playlist
    final songs = await _dbHelper.getSongs();

    if (songs.isEmpty) return;

    // Sample lyrics for demonstration
    final sampleLyrics = [
      {
        'text': '''Raindrops falling on my window
Soft piano notes fill the air
Lost in thoughts of yesterday
Finding peace in moments rare

Coffee cooling by my side
Books stacked high upon the floor
Time moves slowly in this space
Nothing less and nothing more''',
        'isTimeSynced': false,
      },
      {
        'text': '''[00:12.00]Raindrops falling on my window
[00:17.50]Soft piano notes fill the air
[00:23.00]Lost in thoughts of yesterday
[00:28.50]Finding peace in moments rare
[00:34.00]
[00:45.00]Coffee cooling by my side
[00:50.50]Books stacked high upon the floor
[00:56.00]Time moves slowly in this space
[01:01.50]Nothing less and nothing more''',
        'isTimeSynced': true,
      },
    ];

    // Add lyrics to first few songs
    for (int i = 0; i < songs.length && i < 2; i++) {
      final songId = songs[i]['id'] as int;
      final lyrics = Lyrics(
        songId: songId,
        text: sampleLyrics[i % sampleLyrics.length]['text'] as String,
        isTimeSynced:
            sampleLyrics[i % sampleLyrics.length]['isTimeSynced'] as bool,
        language: 'en',
      );
      await _dbHelper.insertLyrics(lyrics.toMap());
    }

    print('Added sample lyrics');
  }

  /// Clear all data and reseed (useful for development)
  Future<void> reseedDatabase() async {
    print('Clearing database...');
    await _dbHelper.clearAllTables();
    await seedDatabase();
  }

  /// Add a single song with lyrics
  Future<int> addSongWithLyrics({
    required String title,
    required String artist,
    required String duration,
    String? album,
    String? genre,
    String? playlistId,
    String? lyricsText,
    bool isTimeSynced = false,
  }) async {
    final song = Song(
      title: title,
      artist: artist,
      duration: duration,
      album: album,
      genre: genre,
      playlistId: playlistId,
    );

    final songId = await _dbHelper.insertSong(song.toMap());

    if (lyricsText != null && lyricsText.isNotEmpty) {
      final lyrics = Lyrics(
        songId: songId,
        text: lyricsText,
        isTimeSynced: isTimeSynced,
      );
      await _dbHelper.insertLyrics(lyrics.toMap());
    }

    return songId;
  }
}
