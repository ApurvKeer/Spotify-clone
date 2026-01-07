/// Player Page
///
/// This file contains:
/// - Music player screen UI
/// - Displays currently playing song
/// - Play/pause controls
/// - Uses Riverpod controllers for playback state
/// - Placeholder UI only (no complex design)
library;
// library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/audio_providers.dart';
import '../controllers/feed_providers.dart';
import '../../domain/entities/repeat_mode.dart';

class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({super.key});

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage> {
  bool _showLyrics = false;

  @override
  Widget build(BuildContext context) {
    final songAsync = ref.watch(currentSongProvider);
    final isPlayingAsync = ref.watch(isPlayingProvider);
    final positionAsync = ref.watch(positionProvider);
    final durationAsync = ref.watch(durationProvider);
    final shuffleEnabled = ref.watch(shuffleStateProvider);
    final repeatMode = ref.watch(repeatStateProvider);
    final actions = ref.watch(audioActionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: songAsync.when(
          data: (song) {
            if (song == null) {
              return const Center(child: Text('No song playing'));
            }

            final isPlaying = isPlayingAsync.asData?.value ?? false;
            final position = positionAsync.asData?.value ?? Duration.zero;
            final duration = durationAsync.asData?.value ?? Duration.zero;
            final progress = _progress(position, duration);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Album art with white border
                Expanded(
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          song.coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.album, size: 96),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Song title and genre
                Text(
                  song.title,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  song.genre,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Progress slider
                Slider(
                  min: 0,
                  max: duration.inMilliseconds.toDouble().clamp(
                    1,
                    double.infinity,
                  ),
                  value: progress,
                  onChanged: (value) {
                    actions.seek(Duration(milliseconds: value.toInt()));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Main controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        shuffleEnabled ? Icons.shuffle_on : Icons.shuffle,
                        color: shuffleEnabled
                            ? Colors.orange
                            : Colors.grey.shade600,
                        size: 24,
                      ),
                      onPressed: actions.toggleShuffle,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      color: Colors.white,
                      iconSize: 32,
                      onPressed: actions.previous,
                    ),
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.black,
                        size: 32,
                      ),
                      iconSize: 56,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: () =>
                          actions.playOrPause(isPlaying: isPlaying),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      color: Colors.white,
                      iconSize: 32,
                      onPressed: actions.next,
                    ),
                    IconButton(
                      icon: Icon(
                        repeatMode == RepeatMode.off
                            ? Icons.repeat
                            : repeatMode == RepeatMode.one
                            ? Icons.repeat_one_on
                            : Icons.repeat_on,
                        color: repeatMode == RepeatMode.off
                            ? Colors.grey.shade600
                            : Colors.orange,
                        size: 24,
                      ),
                      onPressed: actions.toggleRepeat,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Secondary controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      color: Colors.grey,
                      iconSize: 24,
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(
                        ref.watch(likedSongsProvider).contains(song.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: ref.watch(likedSongsProvider).contains(song.id)
                            ? Colors.orange
                            : Colors.grey,
                      ),
                      onPressed: () =>
                          ref.read(likedSongsProvider.notifier).toggle(song.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      color: Colors.grey,
                      iconSize: 24,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  double _progress(Duration position, Duration duration) {
    if (duration.inMilliseconds <= 0) return 0;
    final value = position.inMilliseconds.toDouble();
    final max = duration.inMilliseconds.toDouble();
    if (value < 0) return 0;
    if (value > max) return max;
    return value;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
