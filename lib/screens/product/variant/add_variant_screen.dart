import 'dart:io';
import 'package:ecomerce_app/models/product_model.dart';
import 'package:ecomerce_app/repository/product_repository.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddVariantScreen extends StatefulWidget {
  final ProductModel parentProduct;

  const AddVariantScreen({super.key, required this.parentProduct});

  @override
  _AddVariantScreenState createState() => _AddVariantScreenState();
}

class _AddVariantScreenState extends State<AddVariantScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductRepository _productRepo = ProductRepository();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _stockController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
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

  void _saveVariant() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vui lòng chọn ít nhất một hình ảnh cho biến thể"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ProductModel newVariant = ProductModel(
        parentId: widget.parentProduct.id,
        productName: _nameController.text.trim(),
        description: widget.parentProduct.description,
        price: double.parse(_priceController.text.trim()),
        discount: 0.0,
        brand: widget.parentProduct.brand,
        categoryId: widget.parentProduct.categoryId,
        stock: int.parse(_stockController.text.trim()),
        images: _selectedImages.map((file) => file.path).toList(),
      );

      await _productRepo.addVariant(widget.parentProduct, newVariant);

      if (mounted) {
        Navigator.pop(context, newVariant);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thêm biến thể"),
        backgroundColor: const Color(0xFF7AE582),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildCard("Thông tin biến thể", [
                _buildLabeledTextField("Tên biến thể", _nameController),
                _buildLabeledTextField(
                  "Giá",
                  _priceController,
                  keyboardType: TextInputType.number,
                  isPrice: true,
                ),
                _buildLabeledTextField(
                  "Số lượng",
                  _stockController,
                  keyboardType: TextInputType.number,
                ),
              ]),
              _buildCard("Hình ảnh biến thể", [_buildImagePicker()]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _saveVariant(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7AE582),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Lưu biến thể",
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
      bool isPrice = false}) {
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
            onChanged: isPrice
                ? (value) {
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
                : null,
            validator: (value) =>
                value == null || value.isEmpty ? "Vui lòng nhập $label" : null,
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
