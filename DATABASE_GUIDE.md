# Music Database Implementation

This project now uses **SQLite** for managing songs, playlists, and lyrics. Here's everything you need to know:

## 📁 Database Structure

### Tables

#### 1. **songs**
- `id` - Auto-increment primary key
- `title` - Song title
- `artist` - Artist name
- `album` - Album name (optional)
- `duration` - Song duration (e.g., "3:45")
- `audioPath` - Path to audio file (optional)
- `albumArt` - Path to album artwork (optional)
- `genre` - Music genre (optional)
- `year` - Release year
- `playlistId` - Associated playlist

#### 2. **lyrics**
- `id` - Auto-increment primary key
- `songId` - Foreign key to songs table
- `text` - Lyrics text
- `language` - Language code (default: 'en')
- `isTimeSynced` - Whether lyrics have timestamps (LRC format)

#### 3. **playlists**
- `id` - Playlist ID (string)
- `name` - Playlist name
- `description` - Playlist description
- `coverImage` - Path to cover image

## 🚀 Getting Started

### Initialize Database on First Run

Add to your `main.dart`:

```dart
import 'data/database_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Seed database with initial data
  final seeder = DatabaseSeeder();
  await seeder.seedDatabase();
  
  runApp(const MyApp());
}
```

## 📖 Usage Examples

### Get Songs from a Playlist

```dart
final repository = PlaylistRepository();
final songs = await repository.getSongsByPlaylist('lofi');
```

### Get Lyrics for a Song

```dart
final lyrics = await repository.getLyrics(songId);
if (lyrics != null) {
  print(lyrics.text);
}
```

### Add a New Song with Lyrics

```dart
// Add song
final song = Song(
  title: 'My Song',
  artist: 'Artist Name',
  album: 'Album Name',
  duration: '3:45',
  genre: 'Pop',
  playlistId: 'pop',
);
final songId = await repository.addSong(song);

// Add lyrics
final lyrics = Lyrics(
  songId: songId,
  text: 'Song lyrics here...',
  isTimeSynced: false,
);
await repository.addLyrics(lyrics);
```

### Time-Synced Lyrics (LRC Format)

```dart
final lyrics = Lyrics(
  songId: songId,
  text: '''[00:12.00]First line of lyrics
[00:17.50]Second line of lyrics
[00:23.00]Third line of lyrics''',
  isTimeSynced: true,
);

// Parse time-synced lyrics
final lines = lyrics.parseTimeSyncedLyrics();
for (final line in lines) {
  print('${line.timestamp} - ${line.text}');
}

// Get current line based on playback position
final currentLine = lyrics.getCurrentLine(Duration(seconds: 15));
```

### Search Functionality

```dart
// Search by title, artist, or album
final results = await repository.searchSongs('lofi');

// Search by lyrics content
final songsWithLyrics = await repository.searchByLyrics('love');
```

## 🎵 Using the Lyrics Viewer Widget

Add the `LyricsViewer` widget to your player page:

```dart
import 'ui/player/lyrics_viewer.dart';

// In your player widget
LyricsViewer(
  lyrics: currentLyrics,
  currentPosition: audioPlayer.position,
  autoScroll: true,
)
```

Features:
- **Auto-scroll** for time-synced lyrics
- **Highlighted current line** during playback
- **Centered layout** with smooth animations
- **Fallback message** when no lyrics available

## 🔧 Development Tools

### Reseed Database

```dart
final seeder = DatabaseSeeder();
await seeder.reseedDatabase(); // Clears and reseeds
```

### Add Single Song with Lyrics

```dart
final seeder = DatabaseSeeder();
await seeder.addSongWithLyrics(
  title: 'Song Title',
  artist: 'Artist',
  duration: '3:45',
  lyricsText: 'Lyrics here...',
  isTimeSynced: false,
);
```

## 📝 LRC Format Guidelines

Time-synced lyrics use the LRC format:

```
[mm:ss.xx]Lyric line
```

Example:
```
[00:12.00]First verse begins
[00:17.50]Second line of verse
[00:23.00]Chorus starts here
```

- `mm` - Minutes (00-99)
- `ss` - Seconds (00-59)
- `xx` - Centiseconds (00-99)

## 🗄️ Direct Database Access

For advanced operations, use `DatabaseHelper` directly:

```dart
final db = DatabaseHelper.instance;

// Custom queries
final results = await db.searchSongs('query');

// Get all songs
final allSongs = await db.getSongs();

// Close database
await db.close();
```

## 📱 Migration from CSV

Your existing CSV files are automatically imported on first run. The structure remains:
- `assets/playlists/lofi.csv`
- `assets/playlists/pop.csv`
- `assets/playlists/synthwave.csv`

## 🎯 Next Steps

1. Add actual audio files and update `audioPath` in songs
2. Add album artwork images and update `albumArt`
3. Implement audio playback with the player
4. Add lyrics editing UI
5. Consider adding user-created playlists
6. Implement favorites/liked songs feature
7. Add lyrics import from online sources

## 🐛 Troubleshooting

**Database not created:**
- Make sure to call `WidgetsFlutterBinding.ensureInitialized()` before database operations

**Songs not appearing:**
- Check if `seedDatabase()` was called
- Verify CSV files are in `assets/playlists/`

**Lyrics not syncing:**
- Ensure `isTimeSynced` is set to `true`
- Verify LRC format is correct
- Check that `currentPosition` is being updated
