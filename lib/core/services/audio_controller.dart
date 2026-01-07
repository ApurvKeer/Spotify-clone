/// Audio Controller Service
///
/// Global singleton service for audio playback management using just_audio.
/// Handles playback control, queue management, and exposes streams for state.
library;
// library;

import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../../domain/entities/song.dart';

enum RepeatMode { off, one, all }

class AudioController {
  // Singleton pattern
  AudioController._privateConstructor();
  static final AudioController _instance =
      AudioController._privateConstructor();
  factory AudioController() => _instance;

  // Audio player instance
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Playback state
  List<Song> _queue = [];
  int _currentIndex = -1;
  bool _isShuffle = false;
  RepeatMode _repeatMode = RepeatMode.off;
  List<int> _shuffledIndices = [];

  // Stream controllers
  final _currentSongController = StreamController<Song?>.broadcast();
  final _isPlayingController = StreamController<bool>.broadcast();
  final _shuffleStateController = StreamController<bool>.broadcast();
  final _repeatModeController = StreamController<RepeatMode>.broadcast();

  // Getters for streams
  Stream<Song?> get currentSongStream => _currentSongController.stream;
  Stream<bool> get isPlayingStream => _isPlayingController.stream;
  Stream<bool> get shuffleStateStream => _shuffleStateController.stream;
  Stream<RepeatMode> get repeatModeStream => _repeatModeController.stream;
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;

  // Current state getters
  Song? get currentSong => _currentIndex >= 0 && _currentIndex < _queue.length
      ? _queue[_currentIndex]
      : null;
  bool get isPlaying => _audioPlayer.playing;
  bool get isShuffle => _isShuffle;
  RepeatMode get repeatMode => _repeatMode;
  List<Song> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;

  /// Initialize the audio controller
  Future<void> initialize() async {
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      _isPlayingController.add(state.playing);

      // Handle track completion
      if (state.processingState == ProcessingState.completed) {
        _handleTrackCompletion();
      }
    });

    // Listen to playback events for errors
    _audioPlayer.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace st) {
        // Handle playback errors
        print('Audio playback error: $e');
      },
    );
  }

  /// Play a single song
  Future<void> playSong(Song song) async {
    try {
      _queue = [song];
      _currentIndex = 0;
      _shuffledIndices = [0];
      _currentSongController.add(song);

      await _audioPlayer.setUrl(song.audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing song: $e');
      rethrow;
    }
  }

  /// Play a queue of songs starting at a specific index
  Future<void> playQueue(List<Song> songs, int startIndex) async {
    if (songs.isEmpty) return;
    if (startIndex < 0 || startIndex >= songs.length) {
      throw RangeError('Start index out of bounds');
    }

    try {
      _queue = List.from(songs);
      _currentIndex = startIndex;

      // Reset shuffle indices
      _shuffledIndices = List.generate(_queue.length, (index) => index);
      if (_isShuffle) {
        _shuffleQueue(preserveCurrentIndex: true);
      }

      final song = _queue[_currentIndex];
      _currentSongController.add(song);

      await _audioPlayer.setUrl(song.audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing queue: $e');
      rethrow;
    }
  }

  /// Pause playback
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  /// Resume playback
  Future<void> resume() async {
    await _audioPlayer.play();
  }

  /// Play next song in queue
  Future<void> next() async {
    if (_queue.isEmpty) return;

    int nextIndex;
    if (_isShuffle) {
      final currentShufflePos = _shuffledIndices.indexOf(_currentIndex);
      if (currentShufflePos < _shuffledIndices.length - 1) {
        nextIndex = _shuffledIndices[currentShufflePos + 1];
      } else {
        // End of queue
        if (_repeatMode == RepeatMode.all) {
          nextIndex = _shuffledIndices[0];
        } else {
          return; // Don't play next if at end and not repeating
        }
      }
    } else {
      if (_currentIndex < _queue.length - 1) {
        nextIndex = _currentIndex + 1;
      } else {
        // End of queue
        if (_repeatMode == RepeatMode.all) {
          nextIndex = 0;
        } else {
          return; // Don't play next if at end and not repeating
        }
      }
    }

    await _playAtIndex(nextIndex);
  }

  /// Play previous song in queue
  Future<void> previous() async {
    if (_queue.isEmpty) return;

    // If more than 3 seconds into the song, restart current song
    final position = _audioPlayer.position;
    if (position.inSeconds > 3) {
      await _audioPlayer.seek(Duration.zero);
      return;
    }

    int previousIndex;
    if (_isShuffle) {
      final currentShufflePos = _shuffledIndices.indexOf(_currentIndex);
      if (currentShufflePos > 0) {
        previousIndex = _shuffledIndices[currentShufflePos - 1];
      } else {
        // At start of queue
        if (_repeatMode == RepeatMode.all) {
          previousIndex = _shuffledIndices[_shuffledIndices.length - 1];
        } else {
          // Just restart current song
          await _audioPlayer.seek(Duration.zero);
          return;
        }
      }
    } else {
      if (_currentIndex > 0) {
        previousIndex = _currentIndex - 1;
      } else {
        // At start of queue
        if (_repeatMode == RepeatMode.all) {
          previousIndex = _queue.length - 1;
        } else {
          // Just restart current song
          await _audioPlayer.seek(Duration.zero);
          return;
        }
      }
    }

    await _playAtIndex(previousIndex);
  }

  /// Toggle shuffle mode
  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    _shuffleStateController.add(_isShuffle);

    if (_isShuffle) {
      _shuffleQueue(preserveCurrentIndex: true);
    } else {
      // Reset to sequential order
      _shuffledIndices = List.generate(_queue.length, (index) => index);
    }
  }

  /// Toggle repeat mode (off -> one -> all -> off)
  void toggleRepeat() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.off;
        break;
    }
    _repeatModeController.add(_repeatMode);
  }

  /// Seek to a specific position
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  /// Play song at specific index
  Future<void> _playAtIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;

    try {
      _currentIndex = index;
      final song = _queue[_currentIndex];
      _currentSongController.add(song);

      await _audioPlayer.setUrl(song.audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing song at index $index: $e');
    }
  }

  /// Handle track completion
  void _handleTrackCompletion() {
    if (_repeatMode == RepeatMode.one) {
      // Repeat current song
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
    } else {
      // Play next song
      next();
    }
  }

  /// Shuffle the queue
  void _shuffleQueue({bool preserveCurrentIndex = false}) {
    if (_queue.length <= 1) return;

    _shuffledIndices = List.generate(_queue.length, (index) => index);

    if (preserveCurrentIndex && _currentIndex >= 0) {
      // Remove current index from shuffling
      _shuffledIndices.removeAt(_currentIndex);
      _shuffledIndices.shuffle();
      // Insert current index at the beginning
      _shuffledIndices.insert(0, _currentIndex);
    } else {
      _shuffledIndices.shuffle();
    }
  }

  /// Stop playback and clear queue
  Future<void> stop() async {
    await _audioPlayer.stop();
    _queue.clear();
    _currentIndex = -1;
    _shuffledIndices.clear();
    _currentSongController.add(null);
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _audioPlayer.dispose();
    await _currentSongController.close();
    await _isPlayingController.close();
  }
}
