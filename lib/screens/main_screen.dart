import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'notes_screen.dart';
import 'favorites_screen.dart';
import 'about_screen.dart';
import 'notification_history_screen.dart'; // Import the new screen
import '../widgets/bottom_nav.dart';

final GlobalKey<HomeScreenState> homeScreenKey = GlobalKey<HomeScreenState>();

class MainScreen extends StatefulWidget {
  final int? initialLawNumber;
  const MainScreen({super.key, this.initialLawNumber});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(key: homeScreenKey, initialLawNumber: widget.initialLawNumber), // Pass key and initialLawNumber
      const NotesScreen(),
      const FavoritesScreen(),
      const AboutScreen(),
    ];

    if (widget.initialLawNumber != null) {
      _currentIndex = 0; // Ensure HomeScreen is selected
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageController.jumpToPage(_currentIndex);
      });
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTap(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: BottomNav(
        index: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}