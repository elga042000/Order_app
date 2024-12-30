import 'dart:convert';
import 'package:http/http.dart' as http;

Customer customerFromJSON(String str) => Customer.fromJson(jsonDecode(str));

class Customer {
  final int? customerId;
  final String customerName;
  final String customerCity;
  final String phoneNumber;
  Customer({
    this.customerId,
    required this.customerName,
    required this.customerCity,
    required this.phoneNumber,
  });
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'],
      customerName: json['customerName'],
      customerCity: json['customerCity'],
      phoneNumber: json['phoneNumber'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'customerCity': customerCity,
      'phoneNumber': phoneNumber,
    };
  }
}

class CustomerService {
  final String apiUrl;
  CustomerService(this.apiUrl);
  Future<bool> addCustomer(
      String customerName, String customerCity, String phoneNumber) async {
    final body = jsonEncode({
      'customerName': customerName,
      'customerCity': customerCity,
      'phoneNumber': phoneNumber,
    });
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      throw Exception('Network error occurred: $e');
    }
  }
}

//ADD CUSTOMER
Future<void> submitCustomer(
    String customerName, String customerCity, String phoneNumber) async {
  final url = Uri.parse('http://localhost:5224/api/Order/PostCustomer');
  final body = jsonEncode({
    'customerName': customerName,
    'customerCity': customerCity,
    'phoneNumber': phoneNumber,
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
      Customer.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception(
          'Failed to add customer: ${response.statusCode} ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Network error occurred');
  }
}

//EDIT CUSTOMER
Future<Customer> updateCustomer(int customerId, String customerName,
    String customerCity, String phoneNumber) async {
  final url = Uri.parse('http://localhost:5224/api/Order/EditCustomer');
  final body = jsonEncode({
    'customerId': customerId,
    'customerName': customerName,
    'customerCity': customerCity,
    'phoneNumber': phoneNumber,
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
      return Customer.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception(
          'Failed to update customer: ${response.statusCode} ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Network error occurred: $e');
  }
}

//GET CUSTOMER
Future<List<Customer>> fetchCustomer() async {
  final response = await http
      .get(Uri.parse('http://localhost:5224/api/Order/GetAllCustomers'));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((customer) => Customer.fromJson(customer)).toList();
  } else {
    throw Exception('Failed to load customers');
  }
}

//DELETE CUSTOMER
Future<void> deleteCustomer(int customerId) async {
  final url =
      Uri.parse('http://localhost:5224/api/Order/DeleteCustomer/$customerId');
  try {
    final response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      print('Customer deleted successfully!');
    } else {
      throw Exception(
          'Failed to delete customer: ${response.statusCode} ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Network error occurred: $e');
  }
}

// Order model
class custOrder {
  //final int productId;
  final int orderId;
  final int customerId;
  final String orderDate;
  final double netAmount;
  final List<OrderDetail> orderDetails;
  custOrder({
    // required this.productId,
    required this.orderId,
    required this.customerId,
    required this.orderDate,
    required this.netAmount,
    required this.orderDetails,
  });
  factory custOrder.fromJson(Map<String, dynamic> json) {
    var orderDetailsFromJson = json['orderDetails'] as List;
    List<OrderDetail> orderDetailsList = orderDetailsFromJson
        .map((detail) => OrderDetail.fromJson(detail))
        .toList();
    return custOrder(
      //productId: json['productId'],
      orderId: json['orderId'],
      customerId: json['customerId'],
      orderDate: json['orderDate'],
      netAmount: json['netAmount'],
      orderDetails: orderDetailsList,
    );
  }
}

class OrderDetail {
  //late final int orderId;
  late final int productId;
  final int quantity;
  final double totalAmount;
  OrderDetail({
  // required this.orderId,
    required this.productId,
    required this.quantity,
    required this.totalAmount,
  });
  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
   // orderId: json['orderId'],
      productId: json['productId'],
      quantity: json['quantity'],
      totalAmount: json['totalAmount'],
    );
  }
  get productName => null;

  
}

Future<List<custOrder>> fetchOrders(int customerId) async {
  final response = await http.get(
    Uri.parse('http://localhost:5224/api/Order/getorders/$customerId'),
  );
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((order) => custOrder.fromJson(order)).toList();
  } else {
    throw Exception('Failed to load orders');
  }
}
