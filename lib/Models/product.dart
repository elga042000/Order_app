import 'dart:convert';
import 'package:http/http.dart' as http;
Product productFromJSON(String str) => Product.fromJson(jsonDecode(str));
class Product {
  final int productId;
  final String productName;
  final String productPrice;
  final int stock;
  int quantity;
  
  Product({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.stock,
    this.quantity = 0,
   
  });
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'] is String
          ? int.parse(json['productId'])
          : json['productId'] as int,
      productName: json['productName'] as String,
      productPrice: json['productPrice'].toString(),
      stock: json['stock'],
      quantity: json['quantity'] ?? 0,
    );
  }
}

Future<void> submitproducts(
    String productName, String productPrice, String stock) async {
  final url = Uri.parse('http://localhost:5224/api/Order/PostProducts');
  final body = jsonEncode({
    'productName': productName,
    'productPrice': productPrice,
    'stock': stock,
  });
  try {
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      
      Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception(
          'Failed to add product: ${response.statusCode} ${response.reasonPhrase}');
    }
  } catch (e) {
   
    throw Exception('Network error occurred');
  }
}

Future<List<Product>> fetchProducts() async {
  final response = await http
      .get(Uri.parse('http://localhost:5224/api/Order/GetAllProducts'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((product) => Product.fromJson(product)).toList();
  } else {
    throw Exception('Failed to load products');
  }
}

Future<Product> updateStock(
    int productId, String productName, int stock) async {
  final url = Uri.parse('http://localhost:5224/api/Order/UpdateStock');
  final body = jsonEncode({
    'productId': productId,
    'productName': productName,
    'stock': stock,
  });
  try {
    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Product.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception(
          'Failed to update : ${response.statusCode} ${response.reasonPhrase}');
    }
  } catch (e) {
    
    throw Exception('Network error occurred: $e');
  }
}
