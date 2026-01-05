import 'package:flutter/material.dart';
import '../../data/playlist_repository.dart';
import '../../data/song.dart';

class PlaylistPage extends StatefulWidget {
  final String title;
  final String genre;
  final String image;
  final String playlistId;
  final Function(Song) onPlaySong;

  const PlaylistPage({
    super.key,
    required this.title,
    required this.genre,
    required this.image,
    required this.playlistId,
    required this.onPlaySong,
  });

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final PlaylistRepository _repo = PlaylistRepository();
  late Future<List<Song>> _songsFuture;

  @override
  void initState() {
    super.initState();
    _songsFuture = _repo.getSongsByPlaylist(widget.playlistId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text(widget.title)),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.4,
            child: Image.asset(
              widget.image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[900],
                child: const Icon(Icons.music_note, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final songs = await _repo.getSongsByPlaylist(
                      widget.playlistId,
                    );
                    if (songs.isNotEmpty) {
                      widget.onPlaySong(songs[0]);
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final songs = await _repo.getSongsByPlaylist(
                      widget.playlistId,
                    );
                    if (songs.isNotEmpty) {
                      songs.shuffle();
                      widget.onPlaySong(songs[0]);
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Shuffle'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<Song>>(
              future: _songsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading songs',
                      style: TextStyle(color: Colors.red[300]),
                    ),
                  );
                }
                final songs = snapshot.data ?? [];
                if (songs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No songs found in this playlist',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: songs.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: Colors.white12, height: 1),
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    return ListTile(
                      title: Text(
                        song.title,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${song.artist} • ${song.duration}',
                        style: TextStyle(color: Colors.white70),
                      ),
                      onTap: () {
                        widget.onPlaySong(song);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
