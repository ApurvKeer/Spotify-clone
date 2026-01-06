/// Genre Repository Interface
///
/// Abstract contract for genre data operations.

import '../../domain/entities/genre.dart';

abstract class GenreRepository {
  Future<List<Genre>> getGenres();
}
