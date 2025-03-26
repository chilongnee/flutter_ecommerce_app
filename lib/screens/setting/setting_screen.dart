import 'dart:io';

import 'package:ecomerce_app/models/user_model.dart';
import 'package:ecomerce_app/repository/user_repository.dart';
import 'package:ecomerce_app/screens/widgets/appbar/custom_appbar.dart';
import 'package:ecomerce_app/screens/widgets/form/header_container.dart';
import 'package:ecomerce_app/screens/widgets/form/setting_menu_tile.dart';
import 'package:ecomerce_app/screens/widgets/form/user_profile_tile.dart';
import 'package:ecomerce_app/screens/widgets/text/section_heading_1.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final UserRepository _userRepo = UserRepository();

  final _fullNameController = TextEditingController();

  String? _email;
  String? _linkImage;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    if (user == null) return;

    try {
      UserModel? userModel = await _userRepo.getUserDetails(user!.uid);
      if (userModel != null) {
        setState(() {
          _email = userModel.email;
          _fullNameController.text = userModel.fullName;
          _linkImage = userModel.linkImage;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không tìm thấy dữ liệu người dùng")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi tải dữ liệu: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            HeaderContainer(
              child: Column(
                children: [
                  // AppBar
                  CustomAppBar(
                    title: Text(
                      'Account',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium!.copyWith(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // User Profile Card
                  UserProfileTile(linkImage: _linkImage),
                  const SizedBox(height: 36),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const SectionHeading1(
                    title: 'Cài đặt tài khoản',
                    showActionButton: false,
                  ),

                  SettingMenuTile(
                    icon: Icons.home,
                    title: 'Địa chỉ',
                    subTitle: 'Cài đặt địa chỉ',
                  ),
                  SettingMenuTile(
                    icon: Icons.abc,
                    title: 'AbC',
                    subTitle: 'abc',
                    trailing: Switch(value: false, onChanged: (value) {}),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
