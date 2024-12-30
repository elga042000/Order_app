import 'package:flutter/material.dart';
import 'package:order_taking_app/Models/customer.dart';
import 'package:order_taking_app/Models/order.dart';
import 'package:order_taking_app/common.dart';
import 'package:order_taking_app/screens/order_screen.dart';

class AddCustomers extends StatefulWidget {
  const AddCustomers({super.key});
  @override
  State<AddCustomers> createState() => _AddCustomersState();
}

class _AddCustomersState extends State<AddCustomers> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerCityController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final CustomerService _customerService =
      CustomerService('http://localhost:5224/api/Order/PostCustomer');
  Future<void> submitCustomer(
      String customerName, String customerCity, String phoneNumber) async {
    try {
      final success = await _customerService.addCustomer(
          customerName, customerCity, phoneNumber);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer added successfully!')),
        );
        _customerNameController.clear();
        _customerCityController.clear();
        _numberController.clear();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add customer.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/blueee.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _customerNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _customerCityController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'City',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                maxLength: 10,
                keyboardType: TextInputType.number,
                controller: _numberController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final customerName = _customerNameController.text;
                  final customerCity = _customerCityController.text;
                  final phoneNumber = _numberController.text;
                  if (customerName.isEmpty ||
                      customerCity.isEmpty ||
                      phoneNumber.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please fill in all fields.')),
                    );
                    return;
                  }
                  if (phoneNumber.length != 10) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Phone number must be 10 digits')));
                    return;
                  }
                  await submitCustomer(customerName, customerCity, phoneNumber);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ViewCustomers extends StatefulWidget {
  const ViewCustomers({super.key});

  @override
  State<ViewCustomers> createState() => _ViewCustomersState();
}

class _ViewCustomersState extends State<ViewCustomers> {
  DateTime? selectedDate;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/blueee.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<List<Customer>>(
          future: fetchCustomer(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No customers found.'));
            } else {
              final customers = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  IconButton(
                    icon: Icon(Icons
                        .calendar_today,color: const Color.fromARGB(255, 169, 232, 169),), 
                    onPressed: () => _selectDate(context),
                    tooltip: 'Select date',
                  ),
                  
                  Expanded(
                    child: ListView.builder(
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final customer = customers[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color.fromARGB(255, 116, 141, 178),
                                width: 1.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ListTile(
                            leading: Text(
                              customer.customerId?.toString() ?? 'N/A',
                              style: const TextStyle(color: Colors.white),
                            ),
                            title: Text(
                              customer.customerName,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              customer.customerCity,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  color:
                                      const Color.fromARGB(255, 134, 217, 228),
                                  onPressed: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditCustomerScreen(
                                          customerId: customer.customerId!,
                                          customerName: customer.customerName,
                                          customerCity: customer.customerCity,
                                          phoneNumber: customer.phoneNumber,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Color.fromARGB(255, 204, 70, 60),
                                  ),
                                  onPressed: () async {
                                    bool? confirmDelete =
                                        await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Delete Customer'),
                                          content: const Text(
                                              'Are you sure you want to delete this customer?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (confirmDelete == true) {
                                      try {
                                        await deleteCustomer(
                                            customer.customerId!);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Customer deleted successfully!')),
                                        );
                                        setState(() {});
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Failed to delete customer: $e')),
                                        );
                                      }
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.shopping_basket,
                                    color: Color.fromARGB(255, 188, 222, 148),
                                  ),
                                  onPressed: () async {
                                    if (customer.customerId == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Customer ID or name is missing')),
                                      );
                                      return;
                                    }
                                    //  await _selectDate(context);
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return const AlertDialog(
                                          title: Text('Loading Orders...'),
                                          content: Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        );
                                      },
                                    );

                                    try {
                                      List<custOrder> orders =
                                          await fetchOrders(
                                              customer.customerId!);
                                      Navigator.of(context).pop();
                                      //filtering order based on date
                                      if (selectedDate != null) {
                                        orders = orders.where((order) {
                                          final orderDate =
                                              DateTime.parse(order.orderDate);
                                          return orderDate.year ==
                                                  selectedDate!.year &&
                                              orderDate.month ==
                                                  selectedDate!.month &&
                                              orderDate.day ==
                                                  selectedDate!.day;
                                        }).toList();
                                      }
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                                'Orders for ${customer.customerName}'),
                                            content: SizedBox(
                                              width: double.maxFinite,
                                              child: ListView(
                                                children: orders
                                                    .map((custOrder order) {
                                                  return ListTile(
                                                    title: Text(
                                                        'Order ID: ${order.orderId}'),
                                                    subtitle: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        ...order.orderDetails
                                                            .map((detail) {
                                                          return Text(
                                                            'Product ID: ${detail.productId}, Quantity: ${detail.quantity}, Net Amount: ${detail.totalAmount}',
                                                          );
                                                        }).toList(),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          'Total Amount: ${order.netAmount}',
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          'Date: ${order.orderDate}',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .grey),
                                                        ),
                                                      ],
                                                    ),
                                                    trailing: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                          onPressed: () {
                                                            if (order
                                                                .orderDetails
                                                                .isNotEmpty) {
                                                              Navigator.of(
                                                                      context)
                                                                  .push(
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          EditScreen(
                                                                    orderDetails:
                                                                        order
                                                                            .orderDetails,
                                                                    customerId:
                                                                        order
                                                                            .customerId,
                                                                    orderId: order
                                                                        .orderId,
                                                                  ),
                                                                ),
                                                              );
                                                            } else {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                const SnackBar(
                                                                    content: Text(
                                                                        'No order details available')),
                                                              );
                                                            }
                                                          },
                                                          icon: const Icon(
                                                            Icons.edit,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    23,
                                                                    65,
                                                                    164),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.delete,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    204,
                                                                    70,
                                                                    60),
                                                          ),
                                                          onPressed: () async {
                                                            bool?
                                                                confirmDelete =
                                                                await showDialog<
                                                                    bool>(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  title: const Text(
                                                                      'Delete Order'),
                                                                  content:
                                                                      const Text(
                                                                          'Are you sure you want to delete this order?'),
                                                                  actions: <Widget>[
                                                                    TextButton(
                                                                      onPressed:
                                                                          () =>
                                                                              Navigator.of(context).pop(false),
                                                                      child: const Text(
                                                                          'Cancel'),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () =>
                                                                              Navigator.of(context).pop(true),
                                                                      child: const Text(
                                                                          'Delete'),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                            if (confirmDelete ==
                                                                true) {
                                                              try {
                                                                await deleteOrder(
                                                                    order
                                                                        .orderId);
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          'Order deleted successfully!')),
                                                                );
                                                                setState(() {});
                                                              } catch (e) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                      content: Text(
                                                                          'Failed to delete order: $e')),
                                                                );
                                                              }
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: const Text('Close'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } catch (e) {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Failed to load orders: $e')),
                                      );
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class EditCustomerScreen extends StatefulWidget {
  final int customerId;
  final String customerName;
  final String customerCity;
  final String phoneNumber;
  const EditCustomerScreen({
    Key? key,
    required this.customerId,
    required this.customerName,
    required this.customerCity,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _EditCustomerScreenState createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _numberController;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customerName);
    _cityController = TextEditingController(text: widget.customerCity);
    _numberController = TextEditingController(text: widget.phoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _saveCustomer() async {
    String customerName = _nameController.text.trim();
    String customerCity = _cityController.text.trim();
    String phoneNumber = _numberController.text.trim();

    if (customerName.isEmpty || customerCity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      await updateCustomer(
          widget.customerId, customerName, customerCity, phoneNumber);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer updated successfully!')),
      );
      Navigator.of(context).pop();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer updated succesfully.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/blueee.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                style: const TextStyle(color: Colors.white),
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                style: const TextStyle(color: Colors.white),
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Customer City',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                maxLength: 10,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveCustomer,
                child: const Text("Save"),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
