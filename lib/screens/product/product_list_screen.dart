import 'dart:io';

import 'package:ecomerce_app/models/product_model.dart';
import 'package:ecomerce_app/repository/product_repository.dart';
import 'package:ecomerce_app/screens/product/edit_product_screen.dart';
import 'package:ecomerce_app/screens/product/product_detail_screen.dart';
import 'package:ecomerce_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ProductListScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const ProductListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductRepository _productRepo = ProductRepository();
  List<ProductModel> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products =
        await _productRepo.getProductsByCategory(widget.categoryId);
    setState(() {
      _products = products;
    });
  }

  void _editProduct(ProductModel product) async {
    final updatedProduct = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(product: product),
      ),
    );

    if (updatedProduct != null) {
      setState(() {
        final index = _products.indexWhere((p) => p.id == updatedProduct.id);
        if (index != -1) {
          _products[index] = updatedProduct;
        }
      });
    }
  }

  void _deleteProduct(ProductModel product) async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc muốn xóa '${product.productName}' không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context, true);
              await _productRepo.deleteProduct(product.id!);
              setState(() {
                _products.removeWhere((p) => p.id == product.id);
              });
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sản phẩm - ${widget.categoryName}"),
        backgroundColor: const Color(0xFF7AE582),
      ),
      body: _products.isEmpty
          ? const Center(child: Text("Không có sản phẩm nào"))
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];

                return Slidable(
                  key: Key(product.id ?? ""),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.3,
                    children: [
                      SlidableAction(
                        onPressed: (context) => _editProduct(product),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Sửa',
                      ),
                      SlidableAction(
                        onPressed: (context) => _deleteProduct(product),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Xóa',
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: SizedBox(
                      width: 50,
                      height: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: _buildImage(product.images.isNotEmpty
                            ? product.images[0]
                            : null),
                      ),
                    ),
                    title: Text(
                      product.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      Utils.formatCurrency(product.price),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailScreen(product: product),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
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
}
