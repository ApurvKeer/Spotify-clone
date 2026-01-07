/// Feed Page
///
/// This file contains:
/// - Social feed screen UI
/// - Displays user activity and recommendations
/// - Placeholder UI only (no complex design)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/song.dart';
import '../controllers/firestore_providers.dart';
import '../controllers/feed_providers.dart';
import '../widgets/network_cover_image.dart';

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

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Feed',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: songs.length,
            onPageChanged: (index) => _playAt(index, songs),
            itemBuilder: (context, index) {
              final song = songs[index];
              final liked = ref.watch(likedSongsProvider).contains(song.id);

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: NetworkCoverImage(
                              song.coverUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      song.title,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      song.genre,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share),
                          color: Colors.grey,
                          iconSize: 24,
                          onPressed: () {
                            Share.share(
                              'Check out ${song.title} by ${song.genre} on MusAIc!',
                              subject: song.title,
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: Icon(
                            liked ? Icons.favorite : Icons.favorite_border,
                            color: liked ? Colors.orange : Colors.grey,
                          ),
                          iconSize: 28,
                          onPressed: () => ref
                              .read(likedSongsProvider.notifier)
                              .toggle(song.id),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
