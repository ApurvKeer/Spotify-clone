/// Mock Music Repository
///
/// Provides fixed genres and songs for testing without backend.
library;

import '../../domain/entities/genre.dart';
import '../models/song_model.dart';

class MockMusicRepository {
  MockMusicRepository();

  static final List<Genre> _genres = [
    const Genre(
      id: 'pop',
      name: 'Pop',
      // add a real image URL
      coverUrl: 'https://example.com/cover/pop',
    ),
    const Genre(
      id: 'rock',
      name: 'Rock',
      coverUrl: 'https://example.com/cover/rock',
    ),
    const Genre(
      id: 'jazz',
      name: 'Jazz',
      coverUrl: 'https://example.com/cover/jazz',
    ),
    const Genre(
      id: 'hiphop',
      name: 'Hip-Hop',
      coverUrl: 'https://example.com/cover/hiphop',
    ),
    const Genre(
      id: 'classical',
      name: 'Classical',
      coverUrl: 'https://example.com/cover/classical',
    ),
    const Genre(
      id: 'electronic',
      name: 'Electronic',
      coverUrl: 'https://example.com/cover/electronic',
    ),
  ];

  static final List<SongModel> _songs = [
    // Pop songs
    SongModel(
      id: 'pop1',
      title: 'Sunshine Days',
      artist: 'Ava Ray',
      genre: 'Pop',
      audioUrl: 'https://example.com/audio/pop1.mp3',
      coverUrl: 'https://example.com/cover/pop1',
      lyrics: null,
      duration: 195,
      createdAt: DateTime(2024, 1, 10),
    ),
    SongModel(
      id: 'pop2',
      title: 'City Lights',
      artist: 'Neon Echo',
      genre: 'Pop',
      audioUrl: 'https://example.com/audio/pop2.mp3',
      coverUrl: 'https://example.com/cover/pop2',
      lyrics: null,
      duration: 210,
      createdAt: DateTime(2024, 2, 14),
    ),
    // Rock songs
    SongModel(
      id: 'rock1',
      title: 'Stone Path',
      artist: 'Crimson Tide',
      genre: 'Rock',
      audioUrl: 'https://example.com/audio/rock1.mp3',
      coverUrl: 'https://example.com/cover/rock1',
      lyrics: null,
      duration: 230,
      createdAt: DateTime(2023, 12, 5),
    ),
    SongModel(
      id: 'rock2',
      title: 'Electric Run',
      artist: 'Voltage',
      genre: 'Rock',
      audioUrl: 'https://example.com/audio/rock2.mp3',
      coverUrl: 'https://example.com/cover/rock2',
      lyrics: null,
      duration: 205,
      createdAt: DateTime(2024, 3, 2),
    ),
    // Jazz songs
    SongModel(
      id: 'jazz1',
      title: 'Midnight Blue',
      artist: 'Blue Note Trio',
      genre: 'Jazz',
      audioUrl: 'https://example.com/audio/jazz1.mp3',
      coverUrl: 'https://example.com/cover/jazz1',
      lyrics: null,
      duration: 260,
      createdAt: DateTime(2022, 11, 12),
    ),
    SongModel(
      id: 'jazz2',
      title: 'Autumn Walk',
      artist: 'Golden Leaves',
      genre: 'Jazz',
      audioUrl: 'https://example.com/audio/jazz2.mp3',
      coverUrl: 'https://example.com/cover/jazz2',
      lyrics: null,
      duration: 240,
      createdAt: DateTime(2023, 4, 30),
    ),
    // Hip-Hop songs
    SongModel(
      id: 'hip1',
      title: 'Street Rhythm',
      artist: 'Flow State',
      genre: 'Hip-Hop',
      audioUrl: 'https://example.com/audio/hiphop1.mp3',
      coverUrl: 'https://example.com/cover/hiphop1',
      lyrics: null,
      duration: 198,
      createdAt: DateTime(2024, 5, 20),
    ),
    SongModel(
      id: 'hip2',
      title: 'Night Drive',
      artist: 'Beatline',
      genre: 'Hip-Hop',
      audioUrl: 'https://example.com/audio/hiphop2.mp3',
      coverUrl: 'https://example.com/cover/hiphop2',
      lyrics: null,
      duration: 215,
      createdAt: DateTime(2024, 6, 1),
    ),
    // Classical songs
    SongModel(
      id: 'clas1',
      title: 'Nocturne in D',
      artist: 'S. Turner',
      genre: 'Classical',
      audioUrl: 'https://example.com/audio/classical1.mp3',
      coverUrl: 'https://example.com/cover/classical1',
      lyrics: null,
      duration: 320,
      createdAt: DateTime(2021, 9, 15),
    ),
    SongModel(
      id: 'clas2',
      title: 'Morning Prelude',
      artist: 'A. Fischer',
      genre: 'Classical',
      audioUrl: 'https://example.com/audio/classical2.mp3',
      coverUrl: 'https://example.com/cover/classical2',
      lyrics: null,
      duration: 285,
      createdAt: DateTime(2022, 2, 1),
    ),
    // Electronic songs
    SongModel(
      id: 'elec1',
      title: 'Neon Pulse',
      artist: 'Synthline',
      genre: 'Electronic',
      audioUrl: 'https://example.com/audio/electronic1.mp3',
      coverUrl: 'https://example.com/cover/electronic1',
      lyrics: null,
      duration: 210,
      createdAt: DateTime(2023, 7, 22),
    ),
    SongModel(
      id: 'elec2',
      title: 'Orbit',
      artist: 'Space Drift',
      genre: 'Electronic',
      audioUrl: 'https://example.com/audio/electronic2.mp3',
      coverUrl: 'https://example.com/cover/electronic2',
      lyrics: null,
      duration: 225,
      createdAt: DateTime(2023, 10, 8),
    ),
  ];

  final Map<String, List<SongModel>> _songsByGenre = {
    'pop': [_songs[0], _songs[1]],
    'rock': [_songs[2], _songs[3]],
    'jazz': [_songs[4], _songs[5]],
    'hiphop': [_songs[6], _songs[7]],
    'classical': [_songs[8], _songs[9]],
    'electronic': [_songs[10], _songs[11]],
  };

  Future<List<SongModel>> fetchFeedSongs() async {
    // Return all songs for the feed (mock, in-memory).
    return _songs;
  }

  Future<List<Genre>> fetchGenres() async {
    return _genres;
  }

  Future<List<SongModel>> fetchSongsByGenre(String genreId) async {
    // Filter the in-memory songs by genre
    return _songsByGenre[genreId] ?? [];
  }
}
