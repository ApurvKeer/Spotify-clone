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
    _title = (widget.title ?? '').isNotEmpty ? widget.title! : 'Believer';
    _artist = (widget.artist ?? '').isNotEmpty
        ? widget.artist!
        : 'Imagine Dragons';
    _album = widget.album ?? 'Evolve';
    _cover = widget.cover ?? 'assets/song_art/Photograph.png';
    _duration =
        _parseDuration(widget.durationLabel) ??
        const Duration(minutes: 2, seconds: 55);
  }

  Duration? _parseDuration(String? label) {
    if (label == null || label.trim().isEmpty) return null;
    final parts = label.split(':');
    if (parts.length != 2) return null;
    final minutes = int.tryParse(parts[0]);
    final seconds = int.tryParse(parts[1]);
    if (minutes == null || seconds == null) return null;
    return Duration(minutes: minutes, seconds: seconds);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final artSize = math.min(size.width - 24, size.height * 0.45);

    final bg = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF202020), Color(0xFF0C0C0C)],
    );

    final progress = _duration.inSeconds == 0
        ? 0.0
        : (_positionSeconds / _duration.inSeconds).clamp(0.0, 1.0);

    final remaining = Duration(
      seconds: (_duration.inSeconds - _positionSeconds)
          .clamp(0, double.maxFinite)
          .round(),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(gradient: bg),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(),
                const SizedBox(height: 12),
                Center(
                  child: _AlbumArt(
                    album: _album,
                    cover: _cover,
                    title: _title,
                    artist: _artist,
                    size: artSize,
                  ),
                ),
                const SizedBox(height: 12),
                _ActionRow(),
                const SizedBox(height: 12),
                _ProgressBar(
                  progress: progress,
                  elapsed: Duration(seconds: _positionSeconds.round()),
                  remaining: remaining,
                  onChanged: (v) => setState(() {
                    _positionSeconds = v * _duration.inSeconds;
                  }),
                ),
                const SizedBox(height: 14),
                _ControlsDeck(
                  isPlaying: _isPlaying,
                  isShuffle: _isShuffle,
                  repeat: _repeat,
                  onPlayPause: () => setState(() => _isPlaying = !_isPlaying),
                  onSeekBack: () => setState(() {
                    _positionSeconds = (_positionSeconds - 10).clamp(
                      0,
                      _duration.inSeconds.toDouble(),
                    );
                  }),
                  onSeekForward: () => setState(() {
                    _positionSeconds = (_positionSeconds + 10).clamp(
                      0,
                      _duration.inSeconds.toDouble(),
                    );
                  }),
                  onToggleShuffle: () =>
                      setState(() => _isShuffle = !_isShuffle),
                  onCycleRepeat: () => setState(() {
                    _repeat = RepeatMode
                        .values[(_repeat.index + 1) % RepeatMode.values.length];
                  }),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _AlbumArt extends StatelessWidget {
  final String album;
  final String cover;
  final String title;
  final String artist;
  final double size;

  const _AlbumArt({
    required this.album,
    required this.cover,
    required this.title,
    required this.artist,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 24,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset(
                  cover,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF1E1E24),
                    child: const Icon(Icons.music_note, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          if (album.isNotEmpty)
            Positioned(
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.72),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  album,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  artist,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 6)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Icon(Icons.favorite_border, color: Colors.white, size: 24),
          Icon(Icons.share, color: Colors.white, size: 22),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final Duration elapsed;
  final Duration remaining;
  final ValueChanged<double> onChanged;

  const _ProgressBar({
    required this.progress,
    required this.elapsed,
    required this.remaining,
    required this.onChanged,
  });

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString();
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFE53935),
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              trackHeight: 3,
            ),
            child: Slider(
              value: progress,
              onChanged: onChanged,
              min: 0,
              max: 1,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _fmt(elapsed),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                '-${_fmt(remaining)}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlsDeck extends StatelessWidget {
  final bool isPlaying;
  final bool isShuffle;
  final RepeatMode repeat;
  final VoidCallback onPlayPause;
  final VoidCallback onSeekBack;
  final VoidCallback onSeekForward;
  final VoidCallback onToggleShuffle;
  final VoidCallback onCycleRepeat;

  const _ControlsDeck({
    required this.isPlaying,
    required this.isShuffle,
    required this.repeat,
    required this.onPlayPause,
    required this.onSeekBack,
    required this.onSeekForward,
    required this.onToggleShuffle,
    required this.onCycleRepeat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
            Icons.shuffle,
            color: isShuffle ? const Color(0xFFE53935) : Colors.white70,
            size: 24,
          ),
          onPressed: onToggleShuffle,
        ),
        IconButton(
          icon: const Icon(Icons.skip_previous, color: Colors.white, size: 28),
          onPressed: onSeekBack,
        ),
        IconButton(
          icon: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 36,
          ),
          onPressed: onPlayPause,
        ),
        IconButton(
          icon: const Icon(Icons.skip_next, color: Colors.white, size: 28),
          onPressed: onSeekForward,
        ),
        IconButton(
          icon: Icon(
            repeat == RepeatMode.off
                ? Icons.repeat
                : repeat == RepeatMode.all
                ? Icons.repeat
                : Icons.repeat_one,
            color: repeat == RepeatMode.off
                ? Colors.white70
                : const Color(0xFFE53935),
            size: 24,
          ),
          onPressed: onCycleRepeat,
        ),
      ],
    );
  }
}

enum RepeatMode { off, all, one }
