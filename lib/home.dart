import 'package:ecomerce_app/screens/dashboard/dashboard_screen.dart';
import 'package:ecomerce_app/screens/setting/setting_screen.dart';
import 'package:ecomerce_app/screens/user/user_profile_screen.dart';
import 'package:ecomerce_app/screens/widgets/appbar/custom_bottombar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const DashboardScreen(),
    const SettingScreen(),
  ];

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomBar(
        selectedIndex: _selectedIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}
