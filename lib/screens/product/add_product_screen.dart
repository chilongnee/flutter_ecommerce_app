import 'dart:io';
import 'package:ecomerce_app/models/category_model.dart';
import 'package:ecomerce_app/models/product_model.dart';
import 'package:ecomerce_app/repository/category_repository.dart';
import 'package:ecomerce_app/repository/product_repository.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  TextEditingController _discountController = TextEditingController();
  final ProductRepository _productRepo = ProductRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();

  String? _selectedCategory;
  List<CategoryModel> _categories = [];
  List<File> _selectedImages = [];
  bool _showDiscountInput = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryRepo.getParentCategories();
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

  void _submitProduct(BuildContext context) async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      if (_selectedImages.length < 3) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Vui lòng chọn ít nhất 3 hình ảnh"),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      double discount = double.tryParse(_discountController.text.trim()) ?? 0;
      if (discount > 50) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Giảm giá không thể vượt quá 50%"),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      String cleanPrice = _priceController.text.trim();
      cleanPrice = cleanPrice.replaceAll(RegExp(r'[^\d,]'), '');
      cleanPrice = cleanPrice.replaceAll(',', '.');

      int lastDotIndex = cleanPrice.lastIndexOf(".");
      if (lastDotIndex != -1) {
        String beforeDot = cleanPrice
            .substring(0, lastDotIndex)
            .replaceAll('.', '');
        String afterDot = cleanPrice.substring(lastDotIndex);
        cleanPrice = beforeDot + afterDot;
      }

      if (cleanPrice.isEmpty || cleanPrice == ".") {
        cleanPrice = "0";
      }

      double price = double.tryParse(cleanPrice) ?? 0.0;

      final product = ProductModel(
        productName: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        brand: _brandController.text.trim(),
        categoryId: _selectedCategory!,
        stock: int.parse(_stockController.text.trim()),
        discount: discount,
        images: _selectedImages.map((file) => file.path).toList(),
      );

      await _productRepo.addProduct(product);

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
        title: const Text("Thêm sản phẩm"),
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
                _buildLabeledTextField(
                  "Mô tả sản phẩm",
                  _descriptionController,
                  minLines: 5,
                  maxLines: null,
                  isDescription: true,
                ),
              ]),
              _buildCard("Giá & Số lượng", [
                _buildLabeledTextField(
                  "Giá sản phẩm",
                  _priceController,
                  keyboardType: TextInputType.number,
                  isPrice: true,
                ),
                _buildLabeledTextField(
                  "Số lượng trong kho",
                  _stockController,
                  keyboardType: TextInputType.number,
                ),
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
                    child: const Text(
                      "Áp dụng giảm giá",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                if (_showDiscountInput)
                  _buildLabeledTextField(
                    "Giảm giá (%)",
                    _discountController,
                    keyboardType: TextInputType.number,
                    isDiscount: true,
                  ),
              ]),
              _buildCard("Hình ảnh", [_buildImagePicker()]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _submitProduct(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7AE582),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Thêm sản phẩm",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledTextField(
    String label,
    TextEditingController controller, {
    int minLines = 1,
    int? maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isPrice = false,
    bool isDiscount = false,
    bool isDescription = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            minLines: minLines,
            maxLines: maxLines,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
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
                      "${formatter.format(int.parse(cleanValue))} VNĐ";

                  int cursorPosition = controller.selection.baseOffset;

                  int offset = formattedValue.length - cleanValue.length - 4;
                  int newCursorPosition = cursorPosition + offset;

                  controller.value = TextEditingValue(
                    text: formattedValue,
                    selection: TextSelection.collapsed(
                      offset: newCursorPosition.clamp(
                        0,
                        formattedValue.length - 4,
                      ),
                    ),
                  );
                } else {
                  controller.value = TextEditingValue(
                    text: '',
                    selection: TextSelection.collapsed(offset: 0),
                  );
                }
              }
              if (isDescription) {
                int cursorPosition = controller.selection.baseOffset;
                String oldText = controller.text;

                List<String> lines = value.split("\n");

                lines.removeWhere(
                  (line) => line.trim() == "•" || line.trim().isEmpty,
                );

                for (int i = 0; i < lines.length; i++) {
                  String trimmed = lines[i].trim();

                  if (!trimmed.startsWith("• ")) {
                    lines[i] = "• $trimmed";
                  }
                }

                if (value.endsWith("\n")) {
                  lines.add("");
                }

                if (lines.isEmpty) {
                  controller.clear();
                  return;
                }

                String newText = lines.join("\n");
                if (newText != oldText) {
                  controller.value = TextEditingValue(
                    text: newText,
                    selection: TextSelection.collapsed(
                      offset:
                          cursorPosition + (newText.length - oldText.length),
                    ),
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

              if (isDescription) {
                List<String> lines =
                    value
                        .split("\n")
                        .where((line) => line.trim().isNotEmpty)
                        .toList();
                if (lines.length < 5) {
                  return "Vui lòng nhập ít nhất 5 mô tả";
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Danh mục",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            dropdownColor: Colors.white,
            style: const TextStyle(fontSize: 16, color: Colors.black),
            items:
                _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            validator:
                (value) => value == null ? "Vui lòng chọn danh mục" : null,
          ),
        ),
        const SizedBox(height: 10),
      ],
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
                    color: Colors.grey,
                    style: BorderStyle.solid,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[100],
                ),
                child: const Center(
                  child: Icon(Icons.add_a_photo, color: Colors.grey, size: 30),
                ),
              ),
            ),
            ..._selectedImages.map(
              (file) => Stack(
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
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
