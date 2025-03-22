import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce_app/models/category_model.dart';
import 'package:ecomerce_app/models/user_model.dart';
import 'package:ecomerce_app/repository/category_repository.dart';
import 'package:ecomerce_app/repository/user_repository.dart';
import 'package:ecomerce_app/screens/dashboard/dashboard_product_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final UserRepository _userRepo = UserRepository();
  String _fullName = "Khách hàng";

  // Banner
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _timer;

  final List<String> _bannerImages = [
    'assets/banner1.png',
    'assets/banner2.png',
    'assets/banner3.png',
  ];

  // Category
  final CategoryRepository _categoryRepo = CategoryRepository();
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadCategories();
    _startAutoSlide();
  }

  void _loadUser() async {
    if (_user != null) {
      UserModel? userModel = await _userRepo.getUserDetails(_user.uid);
      if (userModel != null) {
        setState(() {
          _fullName = userModel.fullName;
        });
      }
    }
  }

  void _loadCategories() async {
    List<CategoryModel> categories = await _categoryRepo.getParentCategories();
    Map<String, double> categoryMaxPrice = {};

    if (categories.isEmpty) {
      return;
    }

    for (var category in categories) {
      if (category.id == null) {
        continue;
      }

      double maxPrice = await _getMaxPriceInCategory(category.id!);
      categoryMaxPrice[category.id!] = maxPrice;
    }

    categories.sort(
      (a, b) =>
          (categoryMaxPrice[b.id] ?? 0).compareTo(categoryMaxPrice[a.id] ?? 0),
    );

    setState(() {
      _categories = categories;
    });
  }

  Future<double> _getMaxPriceInCategory(String categoryId) async {
    var querySnapshot =
        await FirebaseFirestore.instance
            .collection('products')
            .where('categoryId', isEqualTo: categoryId)
            .orderBy('price', descending: true)
            .limit(1)
            .get();

    if (querySnapshot.docs.isEmpty) {
      return 0;
    }

    double maxPrice = querySnapshot.docs.first['price'].toDouble();
    return maxPrice;
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "HA SHOP",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                "Xin chào, $_fullName",
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 8),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.black,
              ),
              onPressed: () {
                print("Mở giỏ hàng");
              },
            ),
            IconButton(
              icon: const Icon(Icons.chat_outlined, color: Colors.black),
              onPressed: () {
                print("Mở chat");
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBanner(),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _categories[index].name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 250,
                        child: ProductListView(
                          categoryId: _categories[index].id!,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BANNER
  Widget _buildBanner() {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              int actualIndex = index % _bannerImages.length;
              return Image.asset(
                _bannerImages[actualIndex],
                fit: BoxFit.fill,
                width: double.infinity,
              );
            },
          ),
          Positioned(
            right: 10,
            top: 75,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.7),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.black),
                onPressed: _nextBanner,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_bannerImages.length, (index) {
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width:
                        (_currentPage % _bannerImages.length == index) ? 5 : 8,
                    height:
                        (_currentPage % _bannerImages.length == index)
                            ? 15
                            : 10,
                    decoration: BoxDecoration(
                      shape:
                          (_currentPage % _bannerImages.length == index)
                              ? BoxShape.rectangle
                              : BoxShape.circle,
                      borderRadius:
                          (_currentPage % _bannerImages.length == index)
                              ? BorderRadius.circular(5)
                              : null,
                      color:
                          (_currentPage % _bannerImages.length == index)
                              ? Colors.white
                              : Colors.grey,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.page == _bannerImages.length - 1) {
        _pageController.animateToPage(
          0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.nextPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _nextBanner() {
    if (!_pageController.hasClients) return;

    _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    setState(() {
      _currentPage = (_currentPage) % _bannerImages.length;
    });
  }
}
