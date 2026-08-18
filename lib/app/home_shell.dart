import 'package:flutter/material.dart';

import '../features/discovery/presentation/pages/discovery_page.dart';
import '../features/vibe_search/presentation/pages/vibe_search_page.dart';

/// Bottom-nav shell for the two main sections. IndexedStack keeps both
/// pages alive in memory when switching tabs.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          DiscoveryPage(),
          VibeSearchPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie),
            label: 'For You',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Vibe Search',
          ),
        ],
      ),
    );
  }
}
