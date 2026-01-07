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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Music',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.orange),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16).copyWith(bottom: 120),
            children: [
              const Text(
                'Explore The Album',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
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
        childAspectRatio: 1,
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
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.white, width: 2),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                Image.network(
                  genre.coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.album, size: 48),
                    );
                  },
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
                // Genre name
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Text(
                    genre.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
      padding: const EdgeInsets.all(12),
      child: currentSongAsync.when(
        data: (currentSong) => currentSong == null
            ? const SizedBox(
                height: 70,
                child: Center(
                  child: Text(
                    'No song playing',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              )
            : isPlayingAsync.when(
                data: (isPlaying) => Row(
                  children: [
                    // Album art
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        currentSong.coverUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey.shade700,
                            child: const Icon(Icons.album, color: Colors.white),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Song info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentSong.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            currentSong.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Play button
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause_circle : Icons.play_circle,
                        color: Colors.orange,
                        size: 40,
                      ),
                      onPressed: () =>
                          audioActions.playOrPause(isPlaying: isPlaying),
                    ),
                  ],
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}
