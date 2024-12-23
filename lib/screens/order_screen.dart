import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:order_taking_app/common.dart';
import 'package:order_taking_app/Models/order.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late double netAmount = 0;
  double totalAmount = 0;
  String? selectedCustomer;
  late int customerId;
  late int orderId;
  late int productId;
  String selectedDate = DateTime.now().toLocal().toString().split(' ')[0];
  final TextEditingController totalAmountController = TextEditingController();
  List<Map<String, dynamic>> submittedOrders = [];
  List<Map<String, dynamic>> orderDetails = [];
  List<Map<String, dynamic>> orders = [];
  late final OrderService orderService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments
        as List<Map<String, dynamic>>;
    setState(() {
      orderDetails = args;
      _updateTotalAmount();
    });
  }

  void _updateTotalAmount() {
    double calculatedTotal = 0;
    for (var product in orderDetails) {
      calculatedTotal +=
          double.parse(product['productPrice']) * product['quantity'];
    }
    totalAmountController.text = calculatedTotal.toStringAsFixed(2);
    totalAmount = calculatedTotal;
  }

  Future<List<Map<String, dynamic>>> fetchCustomers() async {
    final response = await http
        .get(Uri.parse('http://localhost:5224/api/Order/GetAllCustomers'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return List<Map<String, dynamic>>.from(jsonResponse.map((customer) => {
            'customerName': customer['customerName'],
            'customerId': customer['customerId'],
          }));
    } else {
      throw Exception('Failed to load customers');
    }
  }

  Future<List<DropdownMenuItem<String>>> fetchCustomersDropdownItems() async {
    final customers = await fetchCustomers();
    return customers.map((customer) {
      return DropdownMenuItem<String>(
        value: customer['customerId'].toString(),
        child: Text(customer['customerName']),
      );
    }).toList();
  }

  void submitOrders() async {
    if (selectedCustomer == null || totalAmountController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Incomplete Details"),
          content: const Text(
              "Please select a customer and ensure total amount is calculated."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }
    List<Map<String, dynamic>> apiOrderDetails = orderDetails.map((product) {
      return {
        "productId": product['productId'],
        "quantity": product['quantity'],
        "totalAmount":
            (double.parse(product['productPrice']) * product['quantity'])
                .toStringAsFixed(2),
      };
    }).toList();
    double netAmount = 0;
    for (var product in orderDetails) {
      netAmount += double.parse(product['productPrice']);
    }
    final response = await http.post(
      Uri.parse('http://localhost:5224/api/Order/POSTorder'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "customerId": customerId,
        "orderDate": selectedDate,
        "netAmount": netAmount.toStringAsFixed(2),
        "OrderDetails": apiOrderDetails,
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        submittedOrders.add({
          'customer': selectedCustomer,
          'orderDate': selectedDate,
          'totalAmount': totalAmount.toStringAsFixed(2),
          'products':
              List<Map<String, dynamic>>.from(orderDetails.map((product) {
            return {
              'productId': product['productId'],
              'productName': product['productName'],
              'quantity': product['quantity'],
              'productPrice':
                  product['productPrice'], 
              'calculatedTotal':
                  (double.parse(product['productPrice']) * product['quantity'])
                      .toStringAsFixed(2),
            };
          })),
        });
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Success"),
          content: const Text("Order submitted successfully!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("Failed to submit order: ${response.body}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _editOrder(Map<String, dynamic> order, Map<String, dynamic> product) {
    final TextEditingController quantityController =
        TextEditingController(text: product['quantity'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Order"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                int newQuantity = int.tryParse(quantityController.text) ??
                    product['quantity'];
                product['quantity'] = newQuantity;
                _updateTotalAmount();
                Navigator.of(context).pop();
                setState(() {});
              },
              child: Text("Save"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  // void _deleteOrder(
  //     Map<String, dynamic> order, Map<String, dynamic> product) async {
  //   int? orderId = order['orderId'];
  //   int? productId = product['productId'];
  //   print(
  //       'Attempting to delete product with ID: $productId from order with ID: $orderId');
  //   if (orderId == null || productId == null) {
  //     print('Error: Order ID or Product ID is null');
  //     return;
  //   }
  //   bool? confirmDelete = await showDialog<bool>(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text("Confirm Deletion"),
  //         content: const Text("Are you sure you want to delete this order?"),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(true),
  //             child: const Text("Yes"),
  //           ),
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(false),
  //             child: const Text("No"),
  //           ),
  //         ],
  //       );
  //     },
  //   );

  //   if (confirmDelete == true) {
  //     try {
  //       await orderService.deleteProductFromOrder(orderId, productId);

  //       setState(() {
  //         order['products'].remove(product);
  //         if (order['products'].isEmpty) {
  //           submittedOrders.remove(order);
  //         }
  //       });

  //       showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           title: const Text("Success"),
  //           content: const Text("Product deleted successfully!"),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(),
  //               child: const Text("OK"),
  //             ),
  //           ],
  //         ),
  //       );
  //     } catch (e) {
  //       showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           title: const Text("Error"),
  //           content: Text("Failed to delete product: $e"),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(),
  //               child: const Text("OK"),
  //             ),
  //           ],
  //         ),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      body: FutureBuilder<List<DropdownMenuItem<String>>>(
        future: fetchCustomersDropdownItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButton<String>(
                          hint: const Text("Select Customer"),
                          value: selectedCustomer,
                          onChanged: (value) {
                            setState(() {
                              selectedCustomer = value!;
                              customerId = int.parse(value);
                            });
                          },
                          items: snapshot.data!,
                        ),
                        Text(selectedDate),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: totalAmountController,
                            decoration: const InputDecoration(
                              labelText: "Total Amount",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            readOnly: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: submitOrders,
                        child: const Text("Submit Order"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Submitted Orders",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    submittedOrders.isNotEmpty
                        ? SingleChildScrollView(
                         
                          child: Table(
                              border: TableBorder.all(),

                    

                              children: [
                                const TableRow(
                                  children: [
                                    TableCell(
                                        child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("Product ID"),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("Product Name"),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("Quantity"),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("Net Amount"),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("Total"),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("Order Date"),
                                    )),
                                    TableCell(
                                        child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("Actions"),
                                    )),
                                  ],
                                ),
                                ...submittedOrders.expand((order) {
                                  return (order['products']
                                          as List<Map<String, dynamic>>)
                                      .map<TableRow>((product) {
                                    return TableRow(
                                      children: [
                                        TableCell(
                                            child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                              product['productId'].toString()),
                                        )),
                                        TableCell(
                                            child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(product['productName']),
                                        )),
                                        TableCell(
                                            child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                              product['quantity'].toString()),
                                        )),
                                        TableCell(
                                            child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(product['productPrice']),
                                        )),
                                        TableCell(
                                            child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(product['calculatedTotal']),
                                        )),
                                        TableCell(
                                            child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(order['orderDate']),
                                        )),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.edit),
                                                  onPressed: () {
                                                    _editOrder(order, product);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList();
                                }).toList(),
                              ],
                            ),
                        )
                        : const Text("No orders submitted yet."),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
