import 'package:flutter/material.dart';
import '../../data/lyrics.dart';

/// Widget to display song lyrics with optional time-sync support
class LyricsViewer extends StatefulWidget {
  final Lyrics? lyrics;
  final Duration? currentPosition;
  final bool autoScroll;

  const LyricsViewer({
    super.key,
    this.lyrics,
    this.currentPosition,
    this.autoScroll = true,
  });

  @override
  State<LyricsViewer> createState() => _LyricsViewerState();
}

class _LyricsViewerState extends State<LyricsViewer> {
  final ScrollController _scrollController = ScrollController();
  int? _currentLineIndex;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LyricsViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.lyrics?.isTimeSynced == true &&
        widget.currentPosition != null &&
        widget.autoScroll) {
      _updateCurrentLine();
    }
  }

  void _updateCurrentLine() {
    if (widget.lyrics == null || widget.currentPosition == null) return;

    final lines = widget.lyrics!.parseTimeSyncedLyrics();

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].timestamp <= widget.currentPosition! &&
          (i == lines.length - 1 ||
              lines[i + 1].timestamp > widget.currentPosition!)) {
        if (_currentLineIndex != i) {
          setState(() {
            _currentLineIndex = i;
          });
          _scrollToLine(i);
        }
        break;
      }
    }
  }

  void _scrollToLine(int index) {
    if (!_scrollController.hasClients) return;

    final position = index * 60.0; // Approximate line height
    _scrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lyrics == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note, size: 64, color: Colors.white.withAlpha(77)),
            const SizedBox(height: 16),
            Text(
              'No lyrics available',
              style: TextStyle(
                color: Colors.white.withAlpha(128),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (widget.lyrics!.isTimeSynced) {
      return _buildTimeSyncedLyrics();
    } else {
      return _buildPlainLyrics();
    }
  }

  Widget _buildTimeSyncedLyrics() {
    final lines = widget.lyrics!.parseTimeSyncedLyrics();

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: lines.length,
      itemBuilder: (context, index) {
        final line = lines[index];
        final isCurrentLine = _currentLineIndex == index;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: isCurrentLine ? 24 : 18,
              fontWeight: isCurrentLine ? FontWeight.bold : FontWeight.normal,
              color: isCurrentLine ? Colors.white : Colors.white.withAlpha(128),
            ),
            child: Text(line.text, textAlign: TextAlign.center),
          ),
        );
      },
    );
  }

  Widget _buildPlainLyrics() {
    final text = widget.lyrics!.text;
    final lines = text.split('\n');

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      children: lines.map((line) {
        if (line.trim().isEmpty) {
          return const SizedBox(height: 16);
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            line,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }).toList(),
    );
  }
}
