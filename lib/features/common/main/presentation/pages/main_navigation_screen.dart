import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../home/presentation/pages/home_screen.dart';
import '../../../../settings/presentation/pages/settings_screen.dart';
// import 'home_screen_binding.dart'; // Commented out for now
// import 'profile_screen_binding.dart'; // Commented out for now
// import 'settings_screen_binding.dart'; // Commented out for now

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

    // Commented out the binding logic since it's not implemented yet
    /*
    if (index == 0) {
      Get.put(HomeScreenBinding()); // Bind Home Screen controller
    } else if (index == 1) {
      Get.put(ProfileScreenBinding()); // Bind Profile Screen controller
    } else if (index == 2) {
      Get.put(SettingsScreenBinding()); // Bind Settings Screen controller
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SkyFeed'),
      ),
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
