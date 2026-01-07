/// Song List Page
///
/// Displays songs for a selected genre with playback controls.
library;
// library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/genre.dart';
import '../../domain/entities/song.dart';
import '../controllers/audio_providers.dart';
import '../controllers/firestore_providers.dart';
import 'player_page.dart';

class SongListPage extends StatefulWidget {
  const SongListPage({super.key, required this.genre});

  final Genre genre;

  @override
  State<SongListPage> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {
  int _currentNavIndex =
      1; // Start at Player index to show we're in a song context

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.genre.name)),
      body: _SongListContentConsumer(genre: widget.genre),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == 0) {
            // Navigate back to home
            Navigator.of(context).pop();
          } else if (index == 1) {
            // Stay on current page (Player context)
            setState(() => _currentNavIndex = 1);
          } else if (index == 2) {
            // Navigate back to home (to then go to feed via main nav)
            Navigator.of(context).pop();
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Player',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feed'),
        ],
      ),
    );
  }
}

class _SongListContentConsumer extends ConsumerWidget {
  const _SongListContentConsumer({required this.genre});

  final Genre genre;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(firestoreSongsByGenreProvider(genre.id));

    return songsAsync.when(
      data: (songs) => _SongListContent(genre: genre, songs: songs),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}

class _SongListContent extends ConsumerWidget {
  const _SongListContent({required this.genre, required this.songs});

  final Genre genre;
  final List<Song> songs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: songs.isEmpty
                    ? null
                    : () => _playQueue(ref, context, songs, 0),
                child: const Text('Play All'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: songs.isEmpty
                    ? null
                    : () => _shuffleAll(ref, context, songs),
                child: const Text('Shuffle All'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: songs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final song = songs[index];
              return ListTile(
                title: Text(song.title),
                subtitle: Text(song.artist),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => _playQueue(ref, context, songs, index),
                ),
                onTap: () => _playQueue(ref, context, songs, index),
              );
            },
            padding: const EdgeInsets.only(bottom: 0),
          ),
        ),
      ],
    );
  }

  Future<void> _playQueue(
    WidgetRef ref,
    BuildContext context,
    List<Song> songs,
    int startIndex,
  ) async {
    final controller = ref.read(audioControllerProvider);
    await controller.playQueue(songs, startIndex);
    if (!context.mounted) return;
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PlayerPage()));
  }

  Future<void> _shuffleAll(
    WidgetRef ref,
    BuildContext context,
    List<Song> songs,
  ) async {
    final shuffled = List<Song>.from(songs)..shuffle();
    await _playQueue(ref, context, shuffled, 0);
  }
}
