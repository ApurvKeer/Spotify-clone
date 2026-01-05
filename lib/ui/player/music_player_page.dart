import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Visual music player page styled like the provided reference (UI only, no audio engine wired).
class MusicPlayerPage extends StatefulWidget {
  final String? title;
  final String? artist;
  final String? album;
  final String? cover;
  final String? durationLabel;

  const MusicPlayerPage({
    super.key,
    this.title,
    this.artist,
    this.album,
    this.cover,
    this.durationLabel,
  });

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  late String _title;
  late String _artist;
  late String _album;
  late String _cover;
  late Duration _duration;

  double _positionSeconds = 0;
  bool _isPlaying = true;
  bool _isShuffle = false;
  RepeatMode _repeat = RepeatMode.off;

  @override
  void initState() {
    super.initState();
    _title = widget.title ?? 'Unknown Title';
    _artist = widget.artist ?? 'Unknown Artist';
    _album = widget.album ?? 'Unknown Album';
    _cover = widget.cover ?? 'assets/album_art/default.jpg';
    _duration =
        _parseDuration(widget.durationLabel) ??
        const Duration(minutes: 2, seconds: 55);
  }

  Duration? _parseDuration(String? label) {
    if (label == null) return null;
    try {
      final parts = label.split(':');
      if (parts.length == 2) {
        return Duration(
          minutes: int.parse(parts[0]),
          seconds: int.parse(parts[1]),
        );
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _AlbumArt(cover: _cover),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Text(
                            _title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _artist,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _ActionRow(
                      isShuffle: _isShuffle,
                      repeat: _repeat,
                      onShuffleToggle: () {
                        setState(() => _isShuffle = !_isShuffle);
                      },
                      onRepeatToggle: () {
                        setState(() {
                          _repeat =
                              RepeatMode.values[(_repeat.index + 1) %
                                  RepeatMode.values.length];
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _ProgressBar(
                      position: Duration(seconds: _positionSeconds.toInt()),
                      duration: _duration,
                      onChanged: (val) {
                        setState(() => _positionSeconds = val);
                      },
                    ),
                    const SizedBox(height: 24),
                    _ControlsDeck(
                      isPlaying: _isPlaying,
                      onPlayPause: () {
                        setState(() => _isPlaying = !_isPlaying);
                      },
                      onPrevious: () {},
                      onNext: () {},
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlbumArt extends StatelessWidget {
  final String cover;
  const _AlbumArt({required this.cover});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      height: 320,
      width: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          cover,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[900],
              child: const Icon(
                Icons.music_note,
                size: 100,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final bool isShuffle;
  final RepeatMode repeat;
  final VoidCallback onShuffleToggle;
  final VoidCallback onRepeatToggle;

  const _ActionRow({
    required this.isShuffle,
    required this.repeat,
    required this.onShuffleToggle,
    required this.onRepeatToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.shuffle,
              color: isShuffle ? Colors.green : Colors.grey[600],
            ),
            onPressed: onShuffleToggle,
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              repeat == RepeatMode.one ? Icons.repeat_one : Icons.repeat,
              color: repeat != RepeatMode.off ? Colors.green : Colors.grey[600],
            ),
            onPressed: onRepeatToggle,
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<double> onChanged;

  const _ProgressBar({
    required this.position,
    required this.duration,
    required this.onChanged,
  });

  String _formatDuration(Duration d) {
    final mins = d.inMinutes.toString().padLeft(2, '0');
    final secs = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.grey[800],
              thumbColor: Colors.white,
              overlayColor: Colors.white.withOpacity(0.2),
            ),
            child: Slider(
              value: position.inSeconds.toDouble(),
              min: 0,
              max: duration.inSeconds.toDouble(),
              onChanged: onChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                Text(
                  _formatDuration(duration),
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlsDeck extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _ControlsDeck({
    required this.isPlaying,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(
              Icons.skip_previous,
              size: 40,
              color: Colors.white,
            ),
            onPressed: onPrevious,
          ),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 40,
                color: Colors.black,
              ),
              onPressed: onPlayPause,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.skip_next, size: 40, color: Colors.white),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

enum RepeatMode { off, all, one }
