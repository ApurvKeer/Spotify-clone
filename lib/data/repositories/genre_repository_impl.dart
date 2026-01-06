/// Genre Repository Implementation
///
/// Implements genre repository using Firestore remote data source.

import '../../domain/entities/genre.dart';
import '../../domain/repositories/genre_repository.dart';
import '../datasources/genre_remote_datasource.dart';

class GenreRepositoryImpl implements GenreRepository {
  final GenreRemoteDataSource _remoteDataSource;

  GenreRepositoryImpl({required GenreRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Genre>> getGenres() async {
    try {
      final models = await _remoteDataSource.getGenresOrdered();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      // Re-throw with consistent error handling
      throw Exception('Repository: Failed to get genres - $e');
    }
  }
}
