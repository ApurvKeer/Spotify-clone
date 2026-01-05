import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../data/nicknames.dart';
import '../../data/database_helper.dart';
import '../../data/song.dart';
import '../playlist/playlist_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];
  int _index = 0;
  late final String _nickname = Nicknames.random();
  final ValueNotifier<String?> _nowPlaying = ValueNotifier<String?>(null);

  Future<bool> _onWillPop() async {
    final nav = _navigatorKeys[_index].currentState!;
    if (nav.canPop()) {
      nav.pop();
      return false;
    }
    return true;
  }

  void _handlePlaySong(Song song) {
    _nowPlaying.value = song.title;
    setState(() => _index = 1);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFCC0000), Colors.black],
            ),
          ),
          child: SafeArea(
            child: IndexedStack(
              index: _index,
              children: [
                Navigator(
                  key: _navigatorKeys[0],
                  onGenerateRoute: (settings) {
                    if (settings.name == 'playlist') {
                      final args = settings.arguments as Map<String, String>;
                      return MaterialPageRoute(
                        builder: (_) => PlaylistPage(
                          title: args['title']!,
                          genre: args['genre']!,
                          image: args['image']!,
                          playlistId: args['playlistId']!,
                          onPlaySong: (song) => _handlePlaySong(song),
                        ),
                      );
                    }
                    return MaterialPageRoute(
                      builder: (_) => _HomeTab(
                        nickname: _nickname,
                        onPlaySong: _handlePlaySong,
                      ),
                    );
                  },
                ),
                Navigator(
                  key: _navigatorKeys[1],
                  onGenerateRoute: (_) => MaterialPageRoute(
                    builder: (_) => _MusicPlayerTab(nowPlaying: _nowPlaying),
                  ),
                ),
                Navigator(
                  key: _navigatorKeys[2],
                  onGenerateRoute: (_) =>
                      MaterialPageRoute(builder: (_) => const _FeedPage()),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.music_note),
              label: 'Player',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_library),
              label: 'Feed',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  final String nickname;
  final Function(Song) onPlaySong;
  const _HomeTab({required this.nickname, required this.onPlaySong});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  late Future<List<Map<String, dynamic>>> _playlistsFuture;

  @override
  void initState() {
    super.initState();
    _playlistsFuture = _loadPlaylists();
  }

  Future<List<Map<String, dynamic>>> _loadPlaylists() async {
    final db = DatabaseHelper.instance;
    final playlists = await db.queryAllPlaylists();

    final mutablePlaylists = playlists.map((playlist) {
      return Map<String, dynamic>.from(playlist);
    }).toList();

    for (final playlist in mutablePlaylists) {
      final playlistId = playlist['id'].toString();
      final songs = await db.querySongsByPlaylist(playlistId);
      if (songs.isNotEmpty && songs[0]['albumArt'] != null) {
        playlist['image'] = songs[0]['albumArt'];
      } else {
        playlist['image'] = 'assets/album_art/default.jpg';
      }
    }

    return mutablePlaylists;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Hello, ${widget.nickname}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const _SettingsPage(),
                  );
                },
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Explore The Album',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _playlistsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading playlists: ${snapshot.error}',
                    style: TextStyle(color: Colors.red[400]),
                  ),
                );
              }

              final playlists = snapshot.data ?? [];
              if (playlists.isEmpty) {
                return const Center(
                  child: Text(
                    'No playlists found',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: playlists.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final item = playlists[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PlaylistPage(
                            title: item['name'] ?? 'Unknown',
                            genre: 'Unknown Genre',
                            image:
                                item['image'] ?? 'assets/album_art/default.jpg',
                            playlistId: item['id'].toString(),
                            onPlaySong: widget.onPlaySong,
                          ),
                        ),
                      );
                    },
                    child: _AlbumCard(
                      title: item['name'] ?? 'Unknown',
                      image: item['image'] ?? 'assets/album_art/default.jpg',
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AlbumCard extends StatelessWidget {
  final String title;
  final String image;
  const _AlbumCard({required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.asset(
                image,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.music_note, color: Colors.white),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MusicPlayerTab extends StatelessWidget {
  final ValueListenable<String?> nowPlaying;
  const _MusicPlayerTab({required this.nowPlaying});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ValueListenableBuilder<String?>(
        valueListenable: nowPlaying,
        builder: (_, song, __) {
          return Text(
            song == null
                ? 'Music Player\n(Select a song to play)'
                : 'Now Playing:\n$song',
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          );
        },
      ),
    );
  }
}

class _FeedPage extends StatelessWidget {
  const _FeedPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Feed', style: TextStyle(color: Colors.white)),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
