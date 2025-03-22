import 'package:ecomerce_app/screens/dashboard/dashboard_screen.dart';
import 'package:ecomerce_app/screens/user/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [DashboardScreen(), UserProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: GNav(
          gap: 8,
          backgroundColor: Colors.white,
          color: Colors.grey[600],
          activeColor: Colors.blue,
          tabBackgroundColor: Colors.blue.withOpacity(0.2),
          padding: const EdgeInsets.all(10),
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          tabs: const [
            GButton(
              icon: Icons.home,
              text: "Trang chủ",
            ),
            GButton(
              icon: Icons.person,
              text: "Tài khoản",
            ),
          ],
        ),
      ),
    );
  }
}
