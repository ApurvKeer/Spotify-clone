/// Firestore Providers
///
/// Riverpod providers for Firestore data sources, repositories, and data.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/feed_remote_datasource.dart';
import '../../data/datasources/genre_remote_datasource.dart';
import '../../data/datasources/song_remote_datasource.dart';
import '../../data/repositories/feed_repository_impl.dart';
import '../../data/repositories/genre_repository_impl.dart';
import '../../data/repositories/song_repository_impl_firestore.dart';
import '../../domain/entities/genre.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/feed_repository.dart';
import '../../domain/repositories/genre_repository.dart';
import '../../domain/repositories/song_repository.dart';

// ===== Data Source Providers =====

final genreRemoteDataSourceProvider = Provider<GenreRemoteDataSource>((ref) {
  return GenreRemoteDataSource(firestore: FirebaseFirestore.instance);
});

final songRemoteDataSourceProvider = Provider<SongRemoteDataSource>((ref) {
  return SongRemoteDataSource(firestore: FirebaseFirestore.instance);
});

final feedRemoteDataSourceProvider = Provider<FeedRemoteDataSource>((ref) {
  final songDataSource = ref.watch(songRemoteDataSourceProvider);
  return FeedRemoteDataSource(
    firestore: FirebaseFirestore.instance,
    songDataSource: songDataSource,
  );
});

// ===== Repository Providers =====

final genreRepositoryProvider = Provider<GenreRepository>((ref) {
  final dataSource = ref.watch(genreRemoteDataSourceProvider);
  return GenreRepositoryImpl(remoteDataSource: dataSource);
});

final songRepositoryProvider = Provider<SongRepository>((ref) {
  final dataSource = ref.watch(songRemoteDataSourceProvider);
  return SongRepositoryImpl(remoteDataSource: dataSource);
});

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final dataSource = ref.watch(feedRemoteDataSourceProvider);
  return FeedRepositoryImpl(remoteDataSource: dataSource);
});

// ===== Data Providers =====

/// Provides list of genres ordered by priority
final firestoreGenresProvider = FutureProvider<List<Genre>>((ref) async {
  final repository = ref.watch(genreRepositoryProvider);
  try {
    return await repository.getGenres();
  } catch (e) {
    // Log error in debug mode
    print('Error fetching genres: $e');
    rethrow;
  }
});

/// Provides songs for a specific genre
final firestoreSongsByGenreProvider = FutureProvider.family<List<Song>, String>(
  (ref, genre) async {
    final repository = ref.watch(songRepositoryProvider);
    try {
      return await repository.getSongsByGenre(genre);
    } catch (e) {
      print('Error fetching songs for genre $genre: $e');
      rethrow;
    }
  },
);

/// Provides feed songs ordered by priority
final firestoreFeedSongsProvider = FutureProvider<List<Song>>((ref) async {
  final repository = ref.watch(feedRepositoryProvider);
  try {
    return await repository.getFeedSongs();
  } catch (e) {
    print('Error fetching feed songs: $e');
    rethrow;
  }
});
