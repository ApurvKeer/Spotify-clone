/// Audio Providers
///
/// Riverpod providers for audio playback state management.
/// Provides access to AudioController singleton and its state streams.
library;
// library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/audio_controller.dart';
import '../../domain/entities/song.dart';

class AudioActions {
  AudioActions(this._controller);

  final AudioController _controller;

  Future<void> playOrPause({required bool isPlaying}) async {
    if (isPlaying) {
      await _controller.pause();
    } else {
      await _controller.resume();
    }
  }

  Future<void> next() async {
    await _controller.next();
  }

  Future<void> previous() async {
    await _controller.previous();
  }

  Future<void> seek(Duration position) async {
    await _controller.seek(position);
  }

  void toggleShuffle() {
    _controller.toggleShuffle();
  }

  void toggleRepeat() {
    _controller.toggleRepeat();
  }
}

/// Provider for AudioController singleton instance
/// This ensures only one instance of AudioController exists throughout the app
final audioControllerProvider = Provider<AudioController>((ref) {
  final controller = AudioController();

  // Initialize the controller
  controller.initialize();

  // Dispose when provider is disposed
  ref.onDispose(() {
    controller.dispose();
  });

  return controller;
});

/// Provider exposing audio control actions for UI
final audioActionsProvider = Provider<AudioActions>((ref) {
  final controller = ref.watch(audioControllerProvider);
  return AudioActions(controller);
});

/// Provider for current playing song stream
/// Returns null when no song is playing
final currentSongProvider = StreamProvider<Song?>((ref) {
  final controller = ref.watch(audioControllerProvider);
  return controller.currentSongStream;
});

/// Provider for playing state stream
/// Returns true when audio is playing, false when paused
final isPlayingProvider = StreamProvider<bool>((ref) {
  final controller = ref.watch(audioControllerProvider);
  return controller.isPlayingStream;
});

/// Provider for current playback position stream
/// Updates continuously during playback
final positionProvider = StreamProvider<Duration>((ref) {
  final controller = ref.watch(audioControllerProvider);
  return controller.positionStream;
});

/// Provider for current song duration stream
/// Returns null until song is loaded
final durationProvider = StreamProvider<Duration?>((ref) {
  final controller = ref.watch(audioControllerProvider);
  return controller.durationStream;
});

/// Provider for current queue
/// Returns immutable list of songs in the queue
final currentQueueProvider = Provider<List<Song>>((ref) {
  final controller = ref.watch(audioControllerProvider);

  // Watch the current song to trigger rebuilds when queue changes
  ref.watch(currentSongProvider);

  return controller.queue;
});

/// Provider for shuffle state
/// Returns true when shuffle is enabled
final shuffleStateProvider = StreamProvider<bool>((ref) {
  final controller = ref.watch(audioControllerProvider);
  return controller.shuffleStateStream;
});

/// Provider for repeat mode state
/// Returns current RepeatMode (off, one, all)
final repeatStateProvider = StreamProvider<RepeatMode>((ref) {
  final controller = ref.watch(audioControllerProvider);
  return controller.repeatModeStream;
});

/// Provider for current queue index
/// Returns -1 when no song is playing
final currentIndexProvider = Provider<int>((ref) {
  final controller = ref.watch(audioControllerProvider);

  // Watch the current song to trigger rebuilds when index changes
  ref.watch(currentSongProvider);

  return controller.currentIndex;
});
