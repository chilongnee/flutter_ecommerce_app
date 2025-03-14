import 'package:ecomerce_app/models/category_model.dart';
import 'package:ecomerce_app/repository/category_repository.dart';
import 'package:ecomerce_app/screens/category/add_category_screen.dart';
import 'package:ecomerce_app/screens/product/product_list_screen.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final CategoryRepository _categoryRepo = CategoryRepository();
  List<CategoryModel> _allCategories = [];
  List<CategoryModel> _filteredCategories = [];
  bool isGridView = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryRepo.getAllCategories();
    setState(() {
      _allCategories = categories;
      _filteredCategories = categories;
    });
  }

  void _navigateToAddCategory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCategoryScreen()),
    );
    _loadCategories();
  }

  void _filterCategories(String query) {
    setState(() {
      _filteredCategories = _allCategories
          .where((category) =>
              category.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _editCategory(CategoryModel category) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCategoryScreen(category: category),
      ),
    );
    _loadCategories();
  }

  void _confirmDeleteCategory(CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text(
            "Bạn có chắc chắn muốn xóa danh mục '${category.name}' không? Điều này sẽ xóa tất cả sản phẩm thuộc danh mục này."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCategory(category.id!);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(String categoryId) async {
    try {
      await _categoryRepo.deleteCategory(categoryId);
      setState(() {
        _allCategories.removeWhere((category) => category.id == categoryId);
        _filteredCategories
            .removeWhere((category) => category.id == categoryId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xóa danh mục thành công")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi xóa danh mục: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Quản lý danh mục"),
        backgroundColor: Colors.green,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddCategory,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Card(
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 20,
                          color: const Color(0xFF7AE582),
                          margin: const EdgeInsets.only(right: 10),
                        ),
                        const Text(
                          "Danh mục",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.list,
                              color: !isGridView
                                  ? const Color(0xFF7AE582)
                                  : Colors.grey),
                          onPressed: () => setState(() => isGridView = false),
                        ),
                        IconButton(
                          icon: Icon(Icons.grid_view,
                              color: isGridView
                                  ? const Color(0xFF7AE582)
                                  : Colors.grey),
                          onPressed: () => setState(() => isGridView = true),
                        ),
                      ],
                    ),
                  ],
                ),

                // Search
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterCategories,
                    decoration: const InputDecoration(
                      hintText: "Tìm kiếm danh mục...",
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                ),

                // Danh sách danh mục
                Expanded(
                  child: _filteredCategories.isEmpty
                      ? const Center(child: Text("Không tìm thấy danh mục nào"))
                      : isGridView
                          ? _buildGridView()
                          : _buildListView(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Grid View
  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(5),
      itemCount: _filteredCategories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.92,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final category = _filteredCategories[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductListScreen(
                    categoryId: category.id!, categoryName: category.name),
              ),
            );
          },
          child: Card(
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImage(category.imageUrl),
                ),
                const SizedBox(height: 10),
                Text(
                  category.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editCategory(category),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDeleteCategory(category),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const Icon(Icons.image_not_supported,
          size: 80, color: Colors.grey);
    }

    if (imagePath.startsWith('/')) {
      return Image.file(File(imagePath),
          width: 80, height: 80, fit: BoxFit.cover);
    } else {
      return Image.network(imagePath, width: 80, height: 80, fit: BoxFit.cover);
    }
  }

  // List View
  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(5),
      itemCount: _filteredCategories.length,
      itemBuilder: (context, index) {
        final category = _filteredCategories[index];
        return Card(
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: _buildImage(category.imageUrl),
            ),
            title: Text(category.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editCategory(category),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteCategory(category),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductListScreen(
                      categoryId: category.id!, categoryName: category.name),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
