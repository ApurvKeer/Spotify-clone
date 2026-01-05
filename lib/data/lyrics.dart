class Lyrics {
  final int? id;
  final int songId;
  final String text;
  final String language;
  final bool isTimeSynced;

  const Lyrics({
    this.id,
    required this.songId,
    required this.text,
    this.language = 'en',
    this.isTimeSynced = false,
  });

  // Convert Lyrics to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'songId': songId,
      'text': text,
      'language': language,
      'isTimeSynced': isTimeSynced ? 1 : 0,
    };
  }

  // Create Lyrics from Map
  factory Lyrics.fromMap(Map<String, dynamic> map) {
    return Lyrics(
      id: map['id'] as int?,
      songId: map['songId'] as int,
      text: map['text'] as String,
      language: map['language'] as String? ?? 'en',
      isTimeSynced: (map['isTimeSynced'] as int? ?? 0) == 1,
    );
  }

  // Parse time-synced lyrics (LRC format)
  // Example: [00:12.00]Line 1 of lyrics
  List<LyricLine> parseTimeSyncedLyrics() {
    if (!isTimeSynced) return [];

    final lines = text.split('\n');
    final List<LyricLine> lyricLines = [];

    for (final line in lines) {
      final match = RegExp(
        r'\[(\d{2}):(\d{2})\.(\d{2})\](.*)',
      ).firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final milliseconds = int.parse(match.group(3)!) * 10;
        final text = match.group(4)!.trim();

        final timestamp = Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds,
        );

        lyricLines.add(LyricLine(timestamp: timestamp, text: text));
      }
    }

    return lyricLines;
  }

  // Convert plain text to time-synced format
  static String toTimeSyncedFormat(List<LyricLine> lines) {
    return lines
        .map((line) {
          final minutes = line.timestamp.inMinutes.toString().padLeft(2, '0');
          final seconds = (line.timestamp.inSeconds % 60).toString().padLeft(
            2,
            '0',
          );
          final centiseconds = (line.timestamp.inMilliseconds % 1000 ~/ 10)
              .toString()
              .padLeft(2, '0');
          return '[$minutes:$seconds.$centiseconds]${line.text}';
        })
        .join('\n');
  }

  // Get current lyric line based on playback position
  LyricLine? getCurrentLine(Duration position) {
    if (!isTimeSynced) return null;

    final lines = parseTimeSyncedLyrics();
    LyricLine? currentLine;

    for (final line in lines) {
      if (line.timestamp <= position) {
        currentLine = line;
      } else {
        break;
      }
    }

    return currentLine;
  }

  // Get plain text without timestamps
  String getPlainText() {
    if (!isTimeSynced) return text;

    final lines = parseTimeSyncedLyrics();
    return lines.map((line) => line.text).join('\n');
  }
}

class LyricLine {
  final Duration timestamp;
  final String text;

  const LyricLine({required this.timestamp, required this.text});

  @override
  String toString() {
    return '${timestamp.inMinutes}:${(timestamp.inSeconds % 60).toString().padLeft(2, '0')} - $text';
  }
}
