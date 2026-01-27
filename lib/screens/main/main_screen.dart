import 'package:flutter/material.dart';
import '../dashboard/dashboard_screen.dart';
import '../profile/profile_screen.dart';
// If you have real screens for these, import them. Otherwise we can keep placeholders or create basic files.
// Assuming folders exist based on previous ls, but maybe files are empty or don't exist yet.
// For now I will import ProfileScreen as requested and keep placeholders for others if files aren't ready,
// BUT the user complains about Profile specifically.
// Let's assume files might exist or not. 
// Safest bet: Import ProfileScreen.
// I will keep placeholders for Elections/Notifications usually, but wait, checking "ls" from step 4
// "elections" and "notifications" are directories.
// Let's blindly import them? No, that might break if files don't exist.
// Let's just fix ProfileScreen for now as requested.

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ElectionsScreen(),
    NotificationsScreen(),
    ProfileScreen(), // This now refers to the imported one
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
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

/* ---------- Placeholder Screens ---------- */

class ElectionsScreen extends StatelessWidget {
  const ElectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Elections Screen',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Notifications Screen',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}

// REMOVED Placeholder ProfileScreen so the imported one is used.
