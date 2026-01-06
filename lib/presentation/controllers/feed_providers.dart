import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/mock_music_repository.dart';
import '../../data/models/song_model.dart';
import 'audio_providers.dart';

final musicRepositoryProvider = Provider((ref) => MockMusicRepository());

/// Provides the feed song list (mocked, local only).
final feedSongsProvider = FutureProvider<List<SongModel>>((ref) async {
  final repo = ref.read(musicRepositoryProvider);
  final songs = await repo.fetchFeedSongs();
  return songs.cast<SongModel>().toList();
});

/// Current feed page index.
final currentFeedIndexProvider = StateProvider<int>((_) => 0);

/// Liked songs stored locally (by song id).
final likedSongsProvider =
    StateNotifierProvider<LikedSongsNotifier, Set<String>>(
      (_) => LikedSongsNotifier(),
    );

class LikedSongsNotifier extends StateNotifier<Set<String>> {
  LikedSongsNotifier() : super(<String>{});

  void toggle(String songId) {
    final next = Set<String>.from(state);
    if (next.contains(songId)) {
      next.remove(songId);
    } else {
      next.add(songId);
    }
    state = next;
  }
}

/// Saved songs stored locally (by song id).
final savedSongsProvider =
    StateNotifierProvider<SavedSongsNotifier, Set<String>>(
      (_) => SavedSongsNotifier(),
    );

class SavedSongsNotifier extends StateNotifier<Set<String>> {
  SavedSongsNotifier() : super(<String>{});

  void toggle(String songId) {
    final next = Set<String>.from(state);
    if (next.contains(songId)) {
      next.remove(songId);
    } else {
      next.add(songId);
    }
    state = next;
  }
}

/// Handles feed playback actions without UI logic.
final feedPlaybackControllerProvider = Provider<FeedPlaybackController>((ref) {
  return FeedPlaybackController(ref);
});

class FeedPlaybackController {
  FeedPlaybackController(this._ref);
  final Ref _ref;

  Future<void> playAt(int index, List<SongModel> songs) async {
    if (songs.isEmpty || index < 0 || index >= songs.length) return;
    final controller = _ref.read(audioControllerProvider);
    await controller.stop();
    await controller.playQueue(
      songs.map((songModel) => songModel.toEntity()).toList(),
      index,
    );
  }
}
