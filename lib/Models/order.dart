import 'dart:convert';
import 'package:http/http.dart' as http;
class Order {
  final int customerId;
  final DateTime orderDate;
  late double netAmount;
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
  late int quantity;
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
Future<void> updateOrders({
  required int orderId,
  required int customerId,
  required String orderDate,
  required double netAmount,
  required List<OrderDetails> orderDetails,
}) async {
  final url = Uri.parse('http://localhost:5224/api/Order/UpdateOrder');
  final body = jsonEncode({
    "orderId": orderId,
    "orderDate": orderDate,
    "customerId": customerId,
    "netAmount": netAmount,
    "OrderDetails": orderDetails.map((order) => order.toJson()).toList(),
  });
  try {
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: body,
    );
    if (response.statusCode == 200) {   
      print('Order updated successfully');
      print(response.body); 
    } else if (response.statusCode == 400) {
      print('Failed to update order: Bad Request');
      print(response.body); 
    } else if (response.statusCode == 404) {
      
      print('Failed to update order: Order not found');
      print(response.body); 
    } else {
      print('Error occurred: ${response.statusCode}');
      print(response.body); 
    }
  } catch (e) {
    print('Network error occurred: $e');
    throw Exception('Network error occurred');
  }
}
