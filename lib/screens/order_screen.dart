import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:order_taking_app/Models/customer.dart';
import 'package:order_taking_app/Models/product.dart';
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
              'productPrice': product['productPrice'],
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
                                          child:
                                              Text(product['calculatedTotal']),
                                        )),
                                        TableCell(
                                            child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(order['orderDate']),
                                        )),
                                      ],
                                    );
                                  }).toList();
                                })
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

class EditScreen extends StatefulWidget {
  final List<OrderDetail> orderDetails;
 
  final int customerId;
  final int orderId;

   EditScreen({
    Key? key,
   
    required this.orderDetails,
    required this.customerId,
    required this.orderId,
  }) : super(key: key);

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late List<TextEditingController> quantityControllers;
  late List<Product> products;
  late List<int?> selectedProductIds;

  @override
  void initState() {
    super.initState();
    quantityControllers = widget.orderDetails
        .map(
            (detail) => TextEditingController(text: detail.quantity.toString()))
        .toList();
    selectedProductIds =
        widget.orderDetails.map((detail) => detail.productId).toList();
    products = [];
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final fetchedProducts = await fetchProducts();
      setState(() {
        products = fetchedProducts;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in quantityControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateOrder() async {
    List<OrderDetails> updatedOrderDetails = [];
    double totalNetAmount = 0.0;
    for (int i = 0; i < widget.orderDetails.length; i++) {
      int updatedQuantity = int.tryParse(quantityControllers[i].text) ?? 0;
      if (updatedQuantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quantity must be greater than zero.')),
        );
        return;
      }

      final selectedProductId = selectedProductIds[i];
      if (selectedProductId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a product.')),
        );
        return;
      }

      Product selectedProduct = products.firstWhere(
        (product) => product.productId == selectedProductId,
        orElse: () => products.first,
      );
      double pricePerItem =
          widget.orderDetails[i].totalAmount / widget.orderDetails[i].quantity;

      double netAmount = updatedQuantity * pricePerItem;

      updatedOrderDetails.add(OrderDetails(
        productId: selectedProductId,
        quantity: updatedQuantity,
        totalAmount: netAmount,
      ));

      totalNetAmount += netAmount;
    }

    try {
      await updateOrders(
        orderId: widget.orderId,
        customerId: widget.customerId,
        orderDate: DateTime.now().toIso8601String(),
        netAmount: totalNetAmount,
        orderDetails: updatedOrderDetails,
      );

      setState(() {
       
       
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order updated successfully!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Order')),
      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: widget.orderDetails.length,
              itemBuilder: (context, index) {
                final detail = widget.orderDetails[index];
                final selectedProductId = selectedProductIds[index];
                final selectedProduct = products.firstWhere(
                  (product) => product.productId == selectedProductId,
                  orElse: () => products.first,
                );
                return ListTile(
                  title: DropdownButton<Product>(
                    value: products.firstWhere(
                      (product) => product.productId == selectedProductId,
                      orElse: () => products.first,
                    ),
                    items: products.map((product) {
                      return DropdownMenuItem<Product>(
                        value: product,
                        child: Text(product.productName),
                      );
                    }).toList(),
                    onChanged: (selectedProduct) {
                      setState(() {
                        selectedProductIds[index] = selectedProduct?.productId;
                      });
                    },
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: quantityControllers[index],
                        decoration:
                            const InputDecoration(labelText: 'Quantity'),
                        keyboardType: TextInputType.number,
                      ),
                      Text('Product ID: ${selectedProductIds[index]}'),
                      Text(
                        'Total Amount: \$${detail.totalAmount.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: Center(
        child: FloatingActionButton(
          onPressed: _updateOrder,
          child: const Icon(Icons.save_rounded),
        ),
      ),
    );
  }
}
