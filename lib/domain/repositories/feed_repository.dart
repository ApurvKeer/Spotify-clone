/// Feed Repository Interface
///
/// Abstract contract for feed data operations.

import '../../domain/entities/song.dart';

abstract class FeedRepository {
  Future<List<Song>> getFeedSongs();
}
