import 'package:flutter/material.dart';
import '../../../../settings/presentation/pages/settings_screen.dart';
import 'home_screen.dart';
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // List of screens for bottom navigation
  final List<Widget> _screens = [
    const HomeScreen(),     // Home Screen
    const SettingsScreen(), // Settings Screen
  ];

  // Selected index for Bottom Navigation
  int _selectedIndex = 0;

  // Method to handle navigation when tab is selected
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Show the selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Set selected index
        onTap: _onItemTapped, // When a tab is selected, change the screen
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
