import 'package:flutter/services.dart' show rootBundle;
import 'database_helper.dart';
import 'song.dart';
import 'lyrics.dart';

class PlaylistRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Get all songs from database
  Future<List<Song>> getAllSongs() async {
    final maps = await _dbHelper.getSongs();
    return maps.map((map) => Song.fromMap(map)).toList();
  }

  // Get songs for a specific playlist
  Future<List<Song>> getSongsByPlaylist(String playlistId) async {
    final maps = await _dbHelper.getSongs(playlistId: playlistId);
    return maps.map((map) => Song.fromMap(map)).toList();
  }

  // Get a single song
  Future<Song?> getSong(int id) async {
    final map = await _dbHelper.getSong(id);
    if (map != null) {
      return Song.fromMap(map);
    }
    return null;
  }

  // Add a new song
  Future<int> addSong(Song song) async {
    return await _dbHelper.insertSong(song.toMap());
  }

  // Update a song
  Future<void> updateSong(Song song) async {
    if (song.id != null) {
      await _dbHelper.updateSong(song.id!, song.toMap());
    }
  }

  // Delete a song
  Future<void> deleteSong(int id) async {
    await _dbHelper.deleteSong(id);
  }

  // Get lyrics for a song
  Future<Lyrics?> getLyrics(int songId) async {
    final map = await _dbHelper.getLyrics(songId);
    if (map != null) {
      return Lyrics.fromMap(map);
    }
    return null;
  }

  // Add lyrics to a song
  Future<int> addLyrics(Lyrics lyrics) async {
    return await _dbHelper.insertLyrics(lyrics.toMap());
  }

  // Update lyrics
  Future<void> updateLyrics(Lyrics lyrics) async {
    if (lyrics.id != null) {
      await _dbHelper.updateLyrics(lyrics.id!, lyrics.toMap());
    }
  }

  // Search songs
  Future<List<Song>> searchSongs(String query) async {
    final maps = await _dbHelper.searchSongs(query);
    return maps.map((map) => Song.fromMap(map)).toList();
  }

  // Search songs by lyrics
  Future<List<Song>> searchByLyrics(String query) async {
    final maps = await _dbHelper.searchLyrics(query);
    return maps.map((map) => Song.fromMap(map)).toList();
  }

  // Get all playlists
  Future<List<Playlist>> getPlaylists() async {
    final maps = await _dbHelper.getPlaylists();
    return maps.map((map) => Playlist.fromMap(map)).toList();
  }

  // Add playlist
  Future<void> addPlaylist(Playlist playlist) async {
    await _dbHelper.insertPlaylist(playlist.toMap());
  }

  // Legacy CSV import - for migrating old data
  Future<void> importFromCSV(String csvAssetPath, String playlistId) async {
    final raw = await rootBundle.loadString(csvAssetPath);
    final lines = raw.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isNotEmpty) lines.removeAt(0); // remove header

    for (final line in lines) {
      final parts = line.split(',');
      if (parts.length >= 3) {
        final song = Song(
          title: parts[0].trim(),
          artist: parts[1].trim(),
          duration: parts[2].trim(),
          playlistId: playlistId,
        );
        await addSong(song);
      }
    }
  }

  // Initialize database with sample data if empty
  Future<void> initializeIfEmpty() async {
    final songs = await getAllSongs();
    if (songs.isEmpty) {
      // Create playlists
      await addPlaylist(
        const Playlist(
          id: 'lofi',
          name: 'Lo-Fi Beats',
          description: 'Chill lo-fi music for studying and relaxation',
        ),
      );
      await addPlaylist(
        const Playlist(
          id: 'pop',
          name: 'Pop Hits',
          description: 'Latest pop music hits',
        ),
      );
      await addPlaylist(
        const Playlist(
          id: 'synthwave',
          name: 'Synthwave',
          description: 'Retro synthwave vibes',
        ),
      );

      // Import songs from CSV files
      await importFromCSV('assets/playlists/lofi.csv', 'lofi');
      await importFromCSV('assets/playlists/pop.csv', 'pop');
      await importFromCSV('assets/playlists/synthwave.csv', 'synthwave');
    }
  }
}
