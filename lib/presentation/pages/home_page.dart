/// Home Page
///
/// This file contains:
/// - Main home screen UI
/// - Displays list of songs and playlists
/// - Uses Riverpod controllers for state management
/// - Placeholder UI only (no complex design)
/// - Navigates to other pages
library;
// library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/genre.dart';
import '../../domain/entities/song.dart';
import '../controllers/firestore_providers.dart';
import '../controllers/audio_providers.dart';
import 'song_list_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genresAsync = ref.watch(firestoreGenresProvider);
    final likedSongsAsync = ref.watch(likedSongsPlaylistProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16).copyWith(bottom: 120),
            children: [
              // Genres Section
              Text(
                'Genres',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              genresAsync.when(
                data: (genres) => _GenreList(genres: genres),
                loading: () => const SizedBox(
                  height: 200,
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
              const SizedBox(height: 12),
              // Liked Songs Card
              likedSongsAsync.when(
                data: (songs) => _LikedSongsCard(songs: songs),
                loading: () => const Card(
                  child: SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _MusicControlBar(ref: ref),
          ),
        ],
      ),
    );
  }
}

class _GenreList extends StatelessWidget {
  const _GenreList({required this.genres});

  final List<Genre> genres;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: genres.length,
      itemBuilder: (context, index) {
        final genre = genres[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SongListPage(genre: genre)),
            );
          },
          child: Card(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.category, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    genre.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LikedSongsCard extends StatelessWidget {
  const _LikedSongsCard({required this.songs});

  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: songs.isEmpty
          ? null
          : () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _LikedSongsPlaylistPage(songs: songs),
                ),
              );
            },
      child: Card(
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.favorite, size: 48, color: Colors.red),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${songs.length} Liked Songs',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    );
  }
}

class _LikedSongsPlaylistPage extends StatelessWidget {
  const _LikedSongsPlaylistPage({required this.songs});

  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liked Songs')),
      body: ListView.separated(
        itemCount: songs.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final song = songs[index];
          return ListTile(
            title: Text(song.title),
            subtitle: Text(song.artist),
            trailing: IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                // Play from liked songs
              },
            ),
          );
        },
      ),
    );
  }
}

class _MusicControlBar extends ConsumerWidget {
  const _MusicControlBar({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSongAsync = ref.watch(currentSongProvider);
    final isPlayingAsync = ref.watch(isPlayingProvider);
    final audioActions = ref.watch(audioActionsProvider);

    return Container(
      color: Colors.grey.shade900,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Song info
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: currentSongAsync.when(
              data: (currentSong) => currentSong == null
                  ? const Text(
                      'No song playing',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentSong.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currentSong.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          // Controls
          isPlayingAsync.when(
            data: (isPlaying) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.white),
                  onPressed: () => audioActions.previous(),
                ),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () =>
                      audioActions.playOrPause(isPlaying: isPlaying),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.white),
                  onPressed: () => audioActions.next(),
                ),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
