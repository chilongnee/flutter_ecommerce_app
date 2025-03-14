import 'dart:io';
import 'package:ecomerce_app/models/product_model.dart';
import 'package:ecomerce_app/repository/product_repository.dart';
import 'package:ecomerce_app/screens/product/variant/add_variant_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductRepository _productRepo = ProductRepository();
  late List<ProductModel> variants = [];
  bool isLoading = true;
  int _currentImageIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentImageIndex);
    _loadVariants();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadVariants() async {
    setState(() => isLoading = true);

    if (widget.product.id != null) {
      variants = await _productRepo.getVariants(widget.product.id!);
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.productName),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImages(widget.product, _currentImageIndex,
                (index) => setState(() => _currentImageIndex = index)),
            const SizedBox(height: 20),
            Text(
              widget.product.productName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Giá: ${formatCurrency(widget.product.price)}",
              style: const TextStyle(fontSize: 18, color: Colors.red),
            ),
            const SizedBox(height: 10),
            Text(
              "Mô tả: ${widget.product.description ?? 'Không có mô tả'}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (variants.isNotEmpty) ...[
              const Text(
                "Biến thể sản phẩm:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: variants.length,
                itemBuilder: (context, index) {
                  final variant = variants[index];
                  return Card(
                    child: ListTile(
                      leading: variant.images.isNotEmpty &&
                              variant.images.first.isNotEmpty
                          ? Image.network(variant.images.first,
                              width: 50, height: 50, fit: BoxFit.cover)
                          : const Icon(Icons.image,
                              size: 50, color: Colors.grey),
                      title: Text(variant.productName),
                      subtitle: Text("Giá: ${variant.price} đ"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(product: variant),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ] else ...[
              const Text(
                "Sản phẩm này không có biến thể.",
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 20),
            if (widget.product.parentId == null)
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final newVariant = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddVariantScreen(parentProduct: widget.product),
                        ),
                      );

                      if (newVariant != null) {
                        _loadVariants();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7AE582),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      "Thêm biến thể",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String formatCurrency(double price) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatter.format(price);
  }

  // Widget _buildImage(String? imagePath) {
  //   if (imagePath == null || imagePath.isEmpty) {
  //     return const Icon(Icons.image_not_supported,
  //         size: 80, color: Colors.grey);
  //   }

  //   if (imagePath.startsWith('/')) {
  //     return Image.file(File(imagePath),
  //         width: 80, height: 80, fit: BoxFit.cover);
  //   } else {
  //     return Image.network(imagePath, width: 80, height: 80, fit: BoxFit.cover);
  //   }
  // }

  Widget _buildImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const Icon(Icons.image_not_supported,
          size: 80, color: Colors.grey);
    }

    if (kIsWeb) {
    return const Icon(Icons.image_not_supported, size: 80, color: Colors.grey);
  }

    File imageFile = File(imagePath);

    if (!imageFile.existsSync()) {
    return const Icon(Icons.broken_image, size: 80, color: Colors.red);
  }

  return Image.file(imageFile, width: 80, height: 80, fit: BoxFit.cover);
  }

  Widget _buildProductImages(
      ProductModel product, int currentIndex, Function(int) onImageChanged) {
    if (product.images.isEmpty) {
      return const Center(
        child: Icon(Icons.image_not_supported, size: 150, color: Colors.grey),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _pageController,
            itemCount: product.images.length,
            onPageChanged: onImageChanged,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildImage(product.images[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        if (product.images.length > 1)
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: product.images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() => _currentImageIndex = index);
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: currentIndex == index
                              ? Colors.green
                              : Colors.transparent,
                          width: 2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: _buildImage(product.images[index]),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
