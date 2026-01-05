import 'package:flutter/material.dart';
import '../ui/splash/splash_page.dart';
import '../ui/home/home_page.dart';
import '../ui/settings/settings_page.dart';
import '../ui/playlist/playlist_page.dart';
import '../ui/player/music_player_page.dart';

class AppRoutes {
  static const String splash_page = '/splash';
  static const String home_page = '/home';
  static const String settings_page = '/settings';
  static const String music_player_page = '/music-player';
  static const String playlist_page = '/playlist';

  Map<String, WidgetBuilder> getRoutes() {
    return {
      splash_page: (context) => const SplashPage(),
      home_page: (context) => const HomePage(),
      settings_page: (context) => const SettingsPage(),
      music_player_page: (context) => const MusicPlayerPage(),
      playlist_page: (context) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return PlaylistPage(
          title: args['title'] ?? 'Unknown Title', // Provide default value
          genre: args['genre'] ?? 'Unknown Genre', // Provide default value
          image:
              args['image'] ??
              'assets/album_art/default.jpg', // Provide default value
          playlistId: args['playlistId'] ?? '', // Provide default value
          onPlaySong: (song) {},
        );
      },
    };
  }
}
