import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    _database ??= await _initDB('music_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS lyrics');
          await db.execute('DROP TABLE IF EXISTS songs');
          await db.execute('DROP TABLE IF EXISTS playlists');
          await _createDB(db, newVersion);
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE playlists (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        coverImage TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        artist TEXT,
        album TEXT,
        duration TEXT,
        playlistId TEXT,
        albumArt TEXT,
        audioPath TEXT,
        genre TEXT,
        year INTEGER,
        FOREIGN KEY (playlistId) REFERENCES playlists(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE lyrics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        songId INTEGER UNIQUE,
        text TEXT,
        language TEXT DEFAULT 'en',
        isTimeSynced INTEGER DEFAULT 0,
        FOREIGN KEY (songId) REFERENCES songs(id)
      )
    ''');
  }

  // Playlist operations
  Future<int> insertPlaylist(Map<String, dynamic> playlist) async {
    final db = await database;
    return await db.insert('playlists', playlist);
  }

  Future<List<Map<String, dynamic>>> queryAllPlaylists() async {
    final db = await database;
    return await db.query('playlists');
  }

  Future<Map<String, dynamic>?> queryPlaylist(String id) async {
    final db = await database;
    final result = await db.query(
      'playlists',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updatePlaylist(String id, Map<String, dynamic> playlist) async {
    final db = await database;
    return await db.update(
      'playlists',
      playlist,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePlaylist(String id) async {
    final db = await database;
    return await db.delete('playlists', where: 'id = ?', whereArgs: [id]);
  }

  // Song operations
  Future<int> insertSong(Map<String, dynamic> song) async {
    final db = await database;
    return await db.insert('songs', song);
  }

  Future<List<Map<String, dynamic>>> getSongs({String? playlistId}) async {
    final db = await database;
    if (playlistId != null) {
      return await db.query(
        'songs',
        where: 'playlistId = ?',
        whereArgs: [playlistId],
      );
    }
    return await db.query('songs');
  }

  Future<List<Map<String, dynamic>>> querySongsByPlaylist(
    String playlistId,
  ) async {
    final db = await database;
    return await db.query(
      'songs',
      where: 'playlistId = ?',
      whereArgs: [playlistId],
    );
  }

  Future<Map<String, dynamic>?> getSong(int id) async {
    final db = await database;
    final result = await db.query('songs', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateSong(int id, Map<String, dynamic> song) async {
    final db = await database;
    return await db.update('songs', song, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteSong(int id) async {
    final db = await database;
    return await db.delete('songs', where: 'id = ?', whereArgs: [id]);
  }

  // Lyrics operations
  Future<int> insertLyrics(Map<String, dynamic> lyrics) async {
    final db = await database;
    return await db.insert('lyrics', lyrics);
  }

  Future<Map<String, dynamic>?> getLyrics(int songId) async {
    final db = await database;
    final result = await db.query(
      'lyrics',
      where: 'songId = ?',
      whereArgs: [songId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateLyrics(int id, Map<String, dynamic> lyrics) async {
    final db = await database;
    return await db.update('lyrics', lyrics, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteLyrics(int songId) async {
    final db = await database;
    return await db.delete('lyrics', where: 'songId = ?', whereArgs: [songId]);
  }

  Future<void> clearAllTables() async {
    final db = await database;
    await db.transaction((txn) async {
      final tables = ['lyrics', 'songs', 'playlists'];
      for (final table in tables) {
        await txn.delete(table);
      }
    });
  }

  Future<List<Map<String, dynamic>>> searchSongs(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      where: 'title LIKE ? OR artist LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return maps;
  }

  Future<List<Map<String, dynamic>>> searchLyrics(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'lyrics',
      where: 'text LIKE ?',
      whereArgs: ['%$query%'],
    );
    return result;
  }

  Future<List<Map<String, dynamic>>> getPlaylists() async {
    final db = await database;
    return await db.query('playlists');
  }
}
