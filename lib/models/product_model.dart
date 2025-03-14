class ProductModel {
  String? id;
  String? parentId;
  String productName;
  String description;
  double price;
  double discount;
  String brand;
  String categoryId;
  int stock;
  double rating;
  List<String> images;
  List<String> variantIds;

  ProductModel({
    this.id,
    this.parentId,
    required this.productName,
    required this.description,
    required this.price,
    this.discount = 0.0,
    required this.brand,
    required this.categoryId,
    required this.stock,
    this.rating = 0.0,
    required this.images,
    this.variantIds = const [],
  });

  ProductModel copyWith({
    String? id,
    String? parentId,
    String? productName,
    String? description,
    double? price,
    double? discount,
    String? brand,
    String? categoryId,
    int? stock,
    double? rating,
    List<String>? images,
    List<String>? variantIds,
  }) {
    return ProductModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      brand: brand ?? this.brand,
      categoryId: categoryId ?? this.categoryId,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      images: images ?? List.from(this.images),
      variantIds: variantIds ?? List.from(this.variantIds),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "parentId": parentId,
      "productName": productName,
      "description": description,
      "price": price,
      "discount": discount,
      "brand": brand,
      "categoryId": categoryId,
      "stock": stock,
      "rating": rating,
      "images": images,
      "variantIds": variantIds,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json, String docId) {
    return ProductModel(
      id: docId,
      parentId: json["parentId"],
      productName: json["productName"],
      description: json["description"],
      price: (json["price"] as num).toDouble(),
      discount: (json["discount"] as num).toDouble(),
      brand: json["brand"],
      categoryId: json["categoryId"],
      stock: json["stock"],
      rating: (json["rating"] as num).toDouble(),
      images: List<String>.from(json["images"]),
      variantIds: List<String>.from(json["variantIds"]),
    );
  }
}
