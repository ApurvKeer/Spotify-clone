/// Song Repository Implementation
///
/// Implements song repository using Firestore remote data source.

import '../../domain/entities/song.dart';
import '../../domain/repositories/song_repository.dart';
import '../datasources/song_remote_datasource.dart';

class SongRepositoryImpl implements SongRepository {
  final SongRemoteDataSource _remoteDataSource;

  SongRepositoryImpl({required SongRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Song>> getSongsByGenre(String genre) async {
    try {
      final models = await _remoteDataSource.getSongsByGenre(genre);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Repository: Failed to get songs by genre - $e');
    }
  }

  @override
  Future<Song?> getSongById(String id) async {
    try {
      final model = await _remoteDataSource.getSongById(id);
      return model?.toEntity();
    } catch (e) {
      throw Exception('Repository: Failed to get song by ID - $e');
    }
  }
}
