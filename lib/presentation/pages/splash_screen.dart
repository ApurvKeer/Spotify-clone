/// Splash Screen
///
/// This file contains:
/// - Initial splash screen with logo placeholder
/// - Displays for 2 seconds before navigating to main app
/// - Minimal styling
library;
// library;

import 'package:flutter/material.dart';
import 'home_page.dart';
import 'player_page.dart';
import 'feed_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScaffold()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          width: 240,
          height: 240,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.asset('assets/logo.png'),
          ),
        ),
      ),
    );
  }
}

/// Main Scaffold
///
/// This file contains:
/// - Main app structure with bottom navigation
/// - IndexedStack to preserve tab state
/// - Three tabs: Home, Player, Feed

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  // Import pages - to be added after imports
  static const List<Widget> _pages = [HomePage(), PlayerPage(), FeedPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF1a1a1a),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
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
