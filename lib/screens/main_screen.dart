import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'notes_screen.dart';
import 'favorites_screen.dart';
import 'about_screen.dart';
import 'notification_history_screen.dart'; // Import the new screen
import '../widgets/bottom_nav.dart';

class MainScreen extends StatefulWidget {
  final int? initialLawNumber; // Add initialLawNumber to MainScreen
  const MainScreen({super.key, this.initialLawNumber});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const HomeScreen(),
    const NotesScreen(),
    const FavoritesScreen(),
    const AboutScreen(),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialLawNumber != null) {
      // If an initial law number is provided, navigate to HomeScreen and show details
      _currentIndex = 0; // Ensure HomeScreen is selected
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // This ensures the HomeScreen is built before trying to show details
        // The HomeScreen itself will handle showing the law details based on initialLawNumber
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