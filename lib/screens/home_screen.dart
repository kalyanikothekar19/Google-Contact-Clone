import 'package:flutter/material.dart';
import 'contact_list_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _favoritesVisited = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ContactListScreen(isActive: _currentIndex == 0),
          if (_favoritesVisited)
            FavoritesScreen(isActive: _currentIndex == 1)
          else
            const SizedBox(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 80,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          FocusManager.instance.primaryFocus?.unfocus();
          if (index == 1) _favoritesVisited = true;
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person), label: 'Contacts'),
          NavigationDestination(icon: Icon(Icons.star), label: 'Favorites'),
        ],
      ),
    );
  }
}
