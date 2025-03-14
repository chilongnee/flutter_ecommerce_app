import 'dart:io';
import 'package:ecomerce_app/models/category_model.dart';
import 'package:ecomerce_app/models/product_model.dart';
import 'package:ecomerce_app/repository/category_repository.dart';
import 'package:ecomerce_app/repository/product_repository.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;

  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _brandController = TextEditingController();
  final _stockController = TextEditingController();
  final _discountController = TextEditingController();
  final _productRepo = ProductRepository();
  final _categoryRepo = CategoryRepository();

  String? _selectedCategory;
  List<CategoryModel> _categories = [];
  List<File> _selectedImages = [];
  bool _showDiscountInput = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProductData();
  }

  void _loadProductData() {
    _nameController.text = widget.product.productName;
    _descriptionController.text = widget.product.description;
    _priceController.text = widget.product.price.toString();
    _brandController.text = widget.product.brand;
    _stockController.text = widget.product.stock.toString();
    _discountController.text = widget.product.discount.toString();
    _selectedCategory = widget.product.categoryId;
    _selectedImages = widget.product.images.map((path) => File(path)).toList();
    if (widget.product.discount > 0) {
      _showDiscountInput = true;
    }
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryRepo.getAllCategories();
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      List<File> newImages =
          pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
      setState(() {
        _selectedImages.addAll(newImages);
      });
    }
  }

  // Future<File> _saveImageLocally(File image) async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final imagesDir = Directory('${directory.path}/images');
  //   if (!await imagesDir.exists()) {
  //     await imagesDir.create(recursive: true);
  //   }
  //   final String fileName = basename(image.path);
  //   final File localImage = File('${imagesDir.path}/$fileName');
  //   await image.copy(localImage.path);
  //   return localImage;
  // }

  void _updateProduct(BuildContext context) async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      if (_selectedImages.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vui lòng chọn ít nhất 3 hình ảnh"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      double discount = double.tryParse(_discountController.text.trim()) ?? 0;
      if (discount > 50) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Giảm giá không thể vượt quá 50%"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final updatedProduct = ProductModel(
        id: widget.product.id,
        productName: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        brand: _brandController.text.trim(),
        categoryId: _selectedCategory!,
        stock: int.parse(_stockController.text.trim()),
        discount: discount,
        images: _selectedImages.map((file) => file.path).toList(),
      );

      await _productRepo.updateProduct(updatedProduct);

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Chỉnh sửa sản phẩm"),
        backgroundColor: const Color(0xFF7AE582),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildCard("Tên sản phẩm & Mô tả", [
                _buildLabeledTextField("Tên sản phẩm", _nameController),
                _buildLabeledTextField("Thương hiệu", _brandController),
                _buildLabeledTextField("Mô tả sản phẩm", _descriptionController,
                    minLines: 5, maxLines: null),
              ]),
              _buildCard("Giá & Số lượng", [
                _buildLabeledTextField("Giá sản phẩm", _priceController,
                    keyboardType: TextInputType.number),
                _buildLabeledTextField("Số lượng trong kho", _stockController,
                    keyboardType: TextInputType.number),
              ]),
              _buildCard("Danh mục", [_buildCategoryDropdown()]),
              _buildCard("Giảm giá", [
                if (!_showDiscountInput)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showDiscountInput = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7AE582),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Áp dụng giảm giá",
                        style: TextStyle(color: Colors.white)),
                  ),
                if (_showDiscountInput)
                  _buildLabeledTextField("Giảm giá (%)", _discountController,
                      keyboardType: TextInputType.number),
              ]),
              _buildCard("Hình ảnh", [_buildImagePicker()]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _updateProduct(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7AE582),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Cập nhật sản phẩm",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 5,
                  height: 20,
                  color: const Color(0xFF7AE582),
                  margin: const EdgeInsets.only(right: 10),
                ),
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledTextField(String label, TextEditingController controller,
      {int minLines = 1,
      int? maxLines = 1,
      TextInputType keyboardType = TextInputType.text,
      bool isPrice = false,
      bool isDiscount = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            minLines: minLines,
            maxLines: maxLines,
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              if (isDiscount) {
                int discount = int.tryParse(value) ?? 0;
                if (discount > 50) {
                  controller.text = "50"; // Giới hạn tối đa 50%
                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length),
                  );
                }
              }
              if (isPrice) {
                String cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
                if (cleanValue.isNotEmpty) {
                  final formatter = NumberFormat("#,###", "vi_VN");
                  String formattedValue =
                      formatter.format(int.parse(cleanValue));
                  controller.value = TextEditingValue(
                    text: "$formattedValue VNĐ",
                    selection: TextSelection.collapsed(
                        offset: formattedValue.length + 4),
                  );
                }
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Vui lòng nhập $label";
              }
              if (isDiscount) {
                int discount = int.tryParse(value) ?? 0;
                if (discount > 50) {
                  return "Giảm giá không thể vượt quá 50%";
                }
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      isExpanded: true,
      items: _categories
          .map((category) => DropdownMenuItem(
                value: category.id,
                child: Text(category.name),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      decoration: const InputDecoration(border: InputBorder.none),
      validator: (value) => value == null ? "Vui lòng chọn danh mục" : null,
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Chọn hình ảnh (${_selectedImages.length}/3+)",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.grey, style: BorderStyle.solid, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[100],
                ),
                child: const Center(
                  child: Icon(Icons.add_a_photo, color: Colors.grey, size: 30),
                ),
              ),
            ),
            ..._selectedImages.map((file) => Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        file,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _removeImage(file),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ],
    );
  }

  void _removeImage(File image) {
    setState(() {
      _selectedImages.remove(image);
    });
  }
}
