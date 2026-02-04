import 'package:flutter/material.dart';
import '../dashboard/dashboard_screen.dart';
import '../elections/elections_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
// For logout redirection if needed (though StreamBuilder handles usually)

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // We need to initialize screens in build or similar if we want to pass callbacks that rely on setState
  
  @override
  Widget build(BuildContext context) {
    // List of screens
    // We recreate them to pass latest state if needed, or stick to const if possible.
    // Dashboard needs callback.
    final List<Widget> screens = [
      DashboardScreen(
        onSwitchToElections: () {
          setState(() {
            _currentIndex = 1; // Switch to Elections tab
          });
        },
      ),
      const ElectionsScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex, // Preserves state of tabs
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00C853),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_vote),
            label: 'Elections',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Wrapper to handle Auth State (Login vs Main) is likely in main.dart root, 
// so this file just handles the authenticated view.
