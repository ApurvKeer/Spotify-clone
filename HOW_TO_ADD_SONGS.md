# How to Add New Songs

Simply edit `assets/songs.json` - no code changes needed!

## Quick Steps:

1. **Add your MP3 file** to the appropriate folder:
   - `assets/audio/lofi/your_song.mp3`
   - `assets/audio/pop/your_song.mp3`
   - `assets/audio/synthwave/your_song.mp3`

2. **Add album art** (optional):
   - `assets/album_art/your_cover.jpg`

3. **Edit `assets/songs.json`** and add a new song entry:

```json
{
  "title": "Your Song Title",
  "artist": "Artist Name",
  "album": "Album Name",
  "duration": "3:45",
  "audioPath": "assets/audio/lofi/your_song.mp3",
  "albumArt": "assets/album_art/your_cover.jpg",
  "genre": "Lo-Fi",
  "year": 2024,
  "playlistId": "lofi",
  "lyrics": "Your lyrics here\nLine 2\nLine 3",
  "isTimeSynced": false
}
```

4. **Run the app** - database updates automatically!

## Song Entry Template:

Copy and paste this template for each new song:

```json
{
  "title": "",
  "artist": "",
  "album": "",
  "duration": "",
  "audioPath": "assets/audio/GENRE/FILE.mp3",
  "albumArt": "assets/album_art/COVER.jpg",
  "genre": "",
  "year": 2024,
  "playlistId": "lofi",
  "lyrics": "",
  "isTimeSynced": false
}
```

## Field Descriptions:

- **title** (required): Song name
- **artist** (required): Artist name
- **album** (optional): Album name
- **duration** (required): Length in format "M:SS" or "MM:SS" (e.g., "3:45")
- **audioPath** (required): Path to your MP3 file
- **albumArt** (optional): Path to cover image
- **genre** (optional): Music genre
- **year** (optional): Release year
- **playlistId** (required): Which playlist - "lofi", "pop", or "synthwave"
- **lyrics** (optional): Song lyrics (use \n for new lines)
- **isTimeSynced** (optional): true for LRC format, false for plain text

## Time-Synced Lyrics Example:

```json
{
  "lyrics": "[00:12.00]First line\n[00:17.50]Second line\n[00:23.00]Third line",
  "isTimeSynced": true
}
```

## Creating New Playlists:

Edit the "playlists" section in `songs.json`:

```json
{
  "id": "rock",
  "name": "Rock Classics",
  "description": "Best rock songs",
  "coverImage": "assets/album_art/rock_cover.jpg"
}
```

Don't forget to create the audio folder: `assets/audio/rock/`

## Important Notes:

✅ **Always use forward slashes** in paths: `assets/audio/lofi/song.mp3`
✅ **Add comma** after each entry except the last one
✅ **Use double quotes** for all strings
✅ **Check JSON syntax** - one missing comma breaks everything!
✅ **Rebuild app** after JSON changes (hot reload won't work)

## JSON Validation:

Before running, validate your JSON at: https://jsonlint.com/

Common mistakes:
- Missing commas between entries
- Extra comma after last entry
- Unescaped quotes in lyrics
- Wrong file paths
