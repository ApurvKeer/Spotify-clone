/// Feed Page
///
/// This file contains:
/// - Social feed screen UI
/// - Displays user activity and recommendations
/// - Placeholder UI only (no complex design)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/song.dart';
import '../controllers/firestore_providers.dart';
import '../controllers/feed_providers.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _playAt(int index, List<Song> songs) async {
    await ref.read(feedPlaybackControllerProvider).playAt(index, songs);
    ref.read(currentFeedIndexProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(firestoreFeedSongsProvider);

    return feedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Failed to load feed')),
      data: (songs) {
        if (songs.isEmpty) {
          return const Center(child: Text('No songs available'));
        }

        return PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: songs.length,
          onPageChanged: (index) => _playAt(index, songs),
          itemBuilder: (context, index) {
            final song = songs[index];
            final liked = ref.watch(likedSongsProvider).contains(song.id);
            final saved = ref.watch(savedSongsProvider).contains(song.id);

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 220,
                            height: 220,
                            color: Colors.grey.shade300,
                            alignment: Alignment.center,
                            child: const Text('Album Art'),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            song.title,
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            song.artist,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Genre: ${song.genre}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                        ),
                        onPressed: () => ref
                            .read(likedSongsProvider.notifier)
                            .toggle(song.id),
                      ),
                      IconButton(
                        icon: Icon(
                          saved ? Icons.bookmark : Icons.bookmark_border,
                        ),
                        onPressed: () => ref
                            .read(savedSongsProvider.notifier)
                            .toggle(song.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {
                          // Local-only placeholder share action.
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
