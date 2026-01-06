import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/song_model.dart';

typedef Song = SongModel;

/// Singleton service for local persistence (no accounts, no cloud).
class HiveStorageService {
  HiveStorageService._();
  static final HiveStorageService instance = HiveStorageService._();

  static const _likedBoxName = 'liked_song_ids_box';
  static const _savedBoxName = 'saved_songs_box';
  static const _lastPlayedBoxName = 'last_played_song_box';

  static const _likedKey = 'liked_song_ids';
  static const _savedKey = 'saved_songs';
  static const _lastPlayedKey = 'last_played_song_id';

  late Box _likedBox;
  late Box _savedBox;
  late Box _lastPlayedBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _likedBox = await Hive.openBox(_likedBoxName);
    _savedBox = await Hive.openBox(_savedBoxName);
    _lastPlayedBox = await Hive.openBox(_lastPlayedBoxName);
  }

  // ---- Liked songs (IDs) ----
  Set<String> getLikedSongIds() {
    final list = (_likedBox.get(_likedKey, defaultValue: <String>[]) as List)
        .cast<String>();
    return list.toSet();
  }

  Future<void> toggleLikedSongId(String songId) async {
    final next = getLikedSongIds();
    if (next.contains(songId)) {
      next.remove(songId);
    } else {
      next.add(songId);
    }
    await _likedBox.put(_likedKey, next.toList());
  }

  // ---- Saved songs (Song JSON) ----
  List<Song> getSavedSongs() {
    final list = (_savedBox.get(_savedKey, defaultValue: <Map>[]) as List)
        .cast<Map>()
        .map((m) => Song.fromJson(Map<String, dynamic>.from(m)))
        .toList(growable: false);
    return list;
  }

  Future<void> saveSong(Song song) async {
    final current = getSavedSongs();
    if (current.any((s) => s.id == song.id)) return;
    final updated = [...current, song];
    await _savedBox.put(_savedKey, updated.map((s) => s.toJson()).toList());
  }

  Future<void> removeSavedSong(String songId) async {
    final updated = getSavedSongs().where((s) => s.id != songId).toList();
    await _savedBox.put(_savedKey, updated.map((s) => s.toJson()).toList());
  }

  bool isSongSaved(String songId) => getSavedSongs().any((s) => s.id == songId);

  // ---- Last played song (ID) ----
  String? getLastPlayedSongId() =>
      _lastPlayedBox.get(_lastPlayedKey) as String?;

  Future<void> setLastPlayedSongId(String songId) async {
    await _lastPlayedBox.put(_lastPlayedKey, songId);
  }

  Future<void> clearLastPlayedSongId() async {
    await _lastPlayedBox.delete(_lastPlayedKey);
  }
}
