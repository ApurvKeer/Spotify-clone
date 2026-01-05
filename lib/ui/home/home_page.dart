import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../data/nicknames.dart';
import '../../data/database_helper.dart';
import '../../data/song.dart';
import '../playlist/playlist_page.dart';
import '../player/music_player_page.dart';

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
  final ValueNotifier<Song?> _currentSong = ValueNotifier<Song?>(null);

  Future<bool> _onWillPop() async {
    final nav = _navigatorKeys[_index].currentState!;
    if (nav.canPop()) {
      nav.pop();
      return false;
    }
    return true;
  }

  void _handlePlaySong(Song song) {
    _currentSong.value = song;
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
                    builder: (_) => _MusicPlayerTab(currentSong: _currentSong),
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
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: Image.asset(
                image,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.music_note,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MusicPlayerTab extends StatelessWidget {
  final ValueListenable<Song?> currentSong;
  const _MusicPlayerTab({required this.currentSong});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Song?>(
      valueListenable: currentSong,
      builder: (context, song, _) {
        if (song == null) {
          return Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.music_note, size: 80, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  Text(
                    'No song playing',
                    style: TextStyle(color: Colors.grey[400], fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a song to play',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        return MusicPlayerPage(
          title: song.title,
          artist: song.artist,
          album: song.album,
          cover: song.albumArt,
          durationLabel: song.duration,
        );
      },
    );
  }
}

class _FeedPage extends StatelessWidget {
  const _FeedPage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library, size: 80, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text(
              'Feed coming soon',
              style: TextStyle(color: Colors.grey[400], fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white),
            title: const Text('About', style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.white),
            title: const Text('Help', style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
