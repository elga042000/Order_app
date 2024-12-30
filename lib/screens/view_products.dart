import 'package:flutter/material.dart';
import 'package:order_taking_app/Models/product.dart';
import 'package:order_taking_app/common.dart';

class ViewProducts extends StatefulWidget {
  const ViewProducts({super.key});
  @override
  State<ViewProducts> createState() => _ViewProductsState();
}

class _ViewProductsState extends State<ViewProducts> {
  List<TextEditingController> _quantityControllers = [];
  List<Product> _filteredProducts = [];
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _quantityControllers) {
      controller.dispose();
    }
    _searchController.dispose();
    super.dispose();
  }

  void placeOrder(int index, List<Product> products) {
    final quantityText = _quantityControllers[index].text;

    if (quantityText.isEmpty || int.tryParse(quantityText) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity.')),
      );
      return;
    }
    final quantity = int.parse(quantityText);
    final product = products[index];
    if (quantity > product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Out of Stock for ${product.productName}.')),
      );
      return;
    }
    print('Placing order for $quantity of product ${product.productName}');
  }

  void _filterProducts(String query, List<Product> products) {
    if (query.isEmpty) {
      _filteredProducts = products;
    } else {
      _filteredProducts = products.where((product) {
        return product.productName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    setState(() {
      _searchQuery = query;
    });
  }

  void _onSearch() {
    _filterProducts(_searchController.text, _filteredProducts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('blueee.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<List<Product>>(
          future: fetchProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No products available.'));
            } else {
              final products = snapshot.data!;
              if (_quantityControllers.isEmpty) {
                _quantityControllers = List.generate(
                  products.length,
                  (index) => TextEditingController(),
                );
              }
              _filteredProducts = products.where((product) {
                return product.productName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());
              }).toList();
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: _searchController,
                      autofocus: true,
                      onChanged: (value) => _filterProducts(value, products),
                      decoration: InputDecoration(
                        labelText: 'Search Products',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          onPressed: _onSearch,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          int columns = (constraints.maxWidth / 200).floor();
                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                            ),
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              final isOutOfStock = product.stock <= 0;
                              return Card(
                                color: isOutOfStock
                                    ? const Color.fromARGB(255, 233, 32, 32)
                                        .withOpacity(0.7)
                                    : const Color.fromARGB(255, 211, 243, 242),
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      
                                      Text(
                                        'ID: ${product.productId}',
                                        style: const TextStyle(
                                            fontFamily: 'JosefinSans',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color:
                                                Color.fromARGB(255, 0, 0, 0)),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        product.productName,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '\$${product.productPrice}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color:
                                                Color.fromARGB(255, 1, 17, 2)),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Stock: ${product.stock}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color:
                                                Color.fromARGB(255, 1, 17, 2)),
                                        textAlign: TextAlign.center,
                                      ),
                                      if (isOutOfStock)
                                        const Text(
                                          'Out of Stock',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                      if (!isOutOfStock)
                                        TextField(
                                          controller:
                                              _quantityControllers[index],
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'Quantity',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      IconButton(
                                        onPressed: () {
                                          if (!isOutOfStock) {
                                            placeOrder(index, products);
                                          }
                                        },
                                        icon: const Icon(Icons.add_box_rounded),
                                        color: const Color.fromARGB(
                                            255, 4, 45, 79),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        List<Map<String, dynamic>> orderDetails = [];
                        for (int i = 0; i < _filteredProducts.length; i++) {
                          final quantityText = _quantityControllers[i].text;
                          if (quantityText.isNotEmpty &&
                              int.tryParse(quantityText) != null &&
                              int.parse(quantityText) > 0) {
                            final quantity = int.parse(quantityText);
                            final product = _filteredProducts[i];
                            if (quantity > product.stock) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Out of Stock for ${product.productName}.')),
                              );
                              return;
                            }
                            orderDetails.add({
                              'productId': product.productId,
                              'productName': product.productName,
                              'productPrice': product.productPrice,
                              'quantity': quantity,
                            });
                          }
                        }
                        if (orderDetails.isNotEmpty) {
                          Navigator.pushNamed(context, '/order',
                              arguments: orderDetails);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please add at least one product to your order.'),
                            ),
                          );
                        }
                      },
                      child: const Text("Proceed"),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
