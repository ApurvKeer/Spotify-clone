/// Feed Repository Implementation
///
/// Implements feed repository using Firestore remote data source.

import '../../domain/entities/song.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_datasource.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource _remoteDataSource;

  FeedRepositoryImpl({required FeedRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Song>> getFeedSongs() async {
    try {
      final models = await _remoteDataSource.getFeedSongs();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Repository: Failed to get feed songs - $e');
    }
  }
}
