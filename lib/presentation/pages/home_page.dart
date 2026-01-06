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
import '../controllers/firestore_providers.dart';
import 'song_list_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genresAsync = ref.watch(firestoreGenresProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: genresAsync.when(
        data: (genres) => _GenreGrid(genres: genres),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _GenreGrid extends StatelessWidget {
  const _GenreGrid({required this.genres});

  final List<Genre> genres;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
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
                  Text(genre.name),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
