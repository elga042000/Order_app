import 'dart:convert';
import 'package:http/http.dart' as http;

class Order {
  final int customerId;
  final DateTime orderDate;
  final double netAmount;
  final List<OrderDetails> orderDetails;

  Order({
    required this.customerId,
    required this.orderDate,
    required this.netAmount,
    required this.orderDetails,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var orderDetailsFromJson = json['orderDetails'] as List;
    List<OrderDetails> orderDetailsList =
        orderDetailsFromJson.map((e) => OrderDetails.fromJson(e)).toList();

    return Order(
      customerId: json['customerId'] as int,
      orderDate: DateTime.parse(json['orderDate']),
      netAmount: (json['netAmount'] as num).toDouble(),
      orderDetails: orderDetailsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'orderDate': orderDate.toIso8601String(),
      'netAmount': netAmount,
      'orderDetails': orderDetails.map((e) => e.toJson()).toList(),
    };
  }
}

class OrderDetails {
  final int productId;
  final int quantity;
  final double totalAmount;

  OrderDetails({
    required this.productId,
    required this.quantity,
    required this.totalAmount,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      productId: json['productId'] as int,
      quantity: json['quantity'] as int,
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'totalAmount': totalAmount,
    };
  }
}

Future<void> submitOrders({
  required int customerId,
  required String orderDate,
  required double netAmount,
  required List<OrderDetails> orders,
}) async {
  final url = Uri.parse('http://localhost:5224/api/Order/POSTorder');

  // Prepare the request body
  final body = jsonEncode({
    "customerId": customerId,
    "orderDate": orderDate,
    "netAmount": netAmount,
    "orderDetails": orders.map((order) => order.toJson()).toList(),
  });

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('Order submitted successfully!');
    } else {
      print('Failed to submit order. Error: ${response.statusCode}');
      throw Exception('Error: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Network error occurred: $e');
    throw Exception('Network error occurred');
  }
}

class OrderService {
  final int orderId;
  final int productId;
  final String baseUrl;

  OrderService({this.baseUrl = 'http://localhost:5224/api/Order',required this.orderId,required this.productId});

  Future<void> deleteProductFromOrder(int orderId, int productId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/deleteproduct/$orderId/$productId'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },

       body: jsonEncode({
        'orderId': orderId,
        'productId': productId,
      }),
    );

    if (response.statusCode == 200) {
      print('Product deleted successfully from the order.');
    } else if (response.statusCode == 404) {
      print('Product not found in the specified order.');
    } else {
      throw Exception(
          'Failed to delete product. Status code: ${response.statusCode}');
    }
  }
}
