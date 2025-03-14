import 'package:ecomerce_app/screens/user/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecomerce_app/services/firebase_auth_service.dart';
import 'package:ecomerce_app/screens/widgets/bottom_nav_button.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentTab = 0;
  late final List<Widget> screens;
  final FirebaseAuthService _auth = FirebaseAuthService();
  @override
  void initState() {
    super.initState();
    print(_auth.currentUser?.email);
    screens = [const UserProfileScreen()];
  }

  void changeTab(int index) {
    setState(() {
      currentTab = index;
      currentScreen = screens[index];
    });
  }

  Widget buildBottomNavigationButton(
    int tabIndex,
    String iconPath,
    String label,
  ) {
    return BottomNavigationButton(
      // bottom_nav_button.dart
      tabIndex: tabIndex,
      iconPath: iconPath,
      label: label,
      isSelected: currentTab == tabIndex,
      onPressed: changeTab,
    );
  }

  late Widget currentScreen;
  @override
  Widget build(BuildContext context) {
    currentScreen = screens[currentTab];

    return Scaffold(
      body: currentScreen,
      backgroundColor: const Color(0xFF7AE582),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        onPressed: () {
          // _showBottomSheet(context);
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildBottomNavigationButton(0, 'profile', 'Profile'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
