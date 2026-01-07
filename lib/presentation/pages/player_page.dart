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
      appBar: AppBar(title: const Text('Now Playing')),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
                // Album art placeholder
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.album, size: 96),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  song.title,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(song.genre, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),

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
                    Text(_formatDuration(position)),
                    Text(_formatDuration(duration)),
                  ],
                ),
                const SizedBox(height: 16),

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        shuffleEnabled ? Icons.shuffle_on : Icons.shuffle,
                      ),
                      onPressed: actions.toggleShuffle,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: actions.previous,
                    ),
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause_circle : Icons.play_circle,
                      ),
                      iconSize: 56,
                      onPressed: () =>
                          actions.playOrPause(isPlaying: isPlaying),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: actions.next,
                    ),
                    IconButton(
                      icon: Icon(
                        repeatMode == RepeatMode.off
                            ? Icons.repeat
                            : repeatMode == RepeatMode.one
                            ? Icons.repeat_one_on
                            : Icons.repeat_on,
                      ),
                      onPressed: actions.toggleRepeat,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        ref.watch(likedSongsProvider).contains(song.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      onPressed: () =>
                          ref.read(likedSongsProvider.notifier).toggle(song.id),
                    ),
                    IconButton(icon: const Icon(Icons.share), onPressed: () {}),
                    IconButton(
                      icon: Icon(
                        _showLyrics ? Icons.keyboard_arrow_down : Icons.lyrics,
                      ),
                      onPressed: () {
                        setState(() {
                          _showLyrics = !_showLyrics;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _showLyrics
                      ? SingleChildScrollView(
                          child: Text(song.lyrics ?? 'No lyrics available'),
                        )
                      : const SizedBox.shrink(),
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
