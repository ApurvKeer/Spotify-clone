import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/song.dart';
import 'audio_providers.dart';

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

  Future<void> playAt(int index, List<Song> songs) async {
    if (songs.isEmpty || index < 0 || index >= songs.length) return;
    final controller = _ref.read(audioControllerProvider);
    await controller.stop();
    await controller.playQueue(songs, index);
  }
}
