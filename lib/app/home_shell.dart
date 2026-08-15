import 'package:flutter/material.dart';

import '../features/discovery/presentation/pages/discovery_page.dart';

/// Bottom-nav shell for the two main sections. IndexedStack keeps both
/// pages alive in memory when switching tabs, so DiscoveryPage doesn't
/// re-fetch every time you tap back to it.
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
          _VibeSearchPlaceholder(),
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

class _VibeSearchPlaceholder extends StatelessWidget {
  const _VibeSearchPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vibe Search')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Semantic vibe search is coming in Phase 2 -- describe a mood and get matching movies.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
