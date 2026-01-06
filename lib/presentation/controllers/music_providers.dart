/// Music Providers
///
/// Riverpod providers for mock music data (genres and songs).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/mock_music_repository.dart';
import '../../domain/entities/genre.dart';
import '../../domain/entities/song.dart';

final musicRepositoryProvider = Provider<MockMusicRepository>((ref) {
  return MockMusicRepository();
});

final genresProvider = FutureProvider<List<Genre>>((ref) async {
  final repo = ref.read(musicRepositoryProvider);
  return repo.fetchGenres();
});

final songsByGenreProvider = FutureProvider.family<List<Song>, String>((
  ref,
  genreId,
) async {
  final repo = ref.read(musicRepositoryProvider);
  final songsModel = await repo.fetchSongsByGenre(genreId);
  return songsModel.map((m) => m.toEntity()).toList();
});
