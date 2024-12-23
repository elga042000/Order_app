import 'package:flutter/material.dart';
import 'package:order_taking_app/common.dart';
import 'package:order_taking_app/screens/customer_screen.dart';
import 'package:order_taking_app/screens/order_screen.dart';
import 'package:order_taking_app/screens/product_screen.dart';
import 'package:order_taking_app/screens/view_products.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/add_customer': (context) => const AddCustomers(),
        '/add_product': (context) => const AddProducts(),
        '/order': (context) => OrderScreen(),
        '/view': (context) => const ViewProducts(),
        '/view_customers': (context) => const ViewCustomers(),
        '/customer': (context) => const CustomerManagement(),
        '/product': (context) => const ProductManagement(),
        '/stock': (context) => const UpdateStock(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _FirstScreenState createState() => _FirstScreenState();
}
class _FirstScreenState extends State<HomeScreen> {
  final double _containerHeight = 100.0;
  final Color _container1Color = const Color.fromARGB(255, 15, 11, 128);
  final Color _container2Color = const Color.fromARGB(255, 7, 56, 96);
  void _navigateTo(String route) {
    Navigator.pushNamed(context, route);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "e-STORE",
          style: TextStyle(
            fontFamily: 'Courgette',
            color: Color.fromARGB(255, 249, 249, 249),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        //leading: Image.asset('assets/logo.jpg',height:24,width:24),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/istockphoto.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () =>
                    _navigateTo('/customer'), 
                child: AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  height: _containerHeight,
                  width: 200.0,
                  color: _container1Color,
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 40.0,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Customer Management',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'JosefinSans',
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _navigateTo('/product'),
                child: AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  height: _containerHeight,
                  width: 200.0,
                  color: _container2Color,
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag,
                        color: Colors.white,
                        size: 40.0,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Product Management',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'JosefinSans',
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _navigateTo('/view'), 
                child: AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  height: _containerHeight,
                  width: 200.0,
                  color: _container1Color,
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_checkout,
                        color: Colors.white,
                        size: 40.0,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Store',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'JosefinSans',
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ClipOval(
                child: Image.asset(
                  'assets/logo_Front.png',
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
class CustomerManagement extends StatelessWidget {
  const CustomerManagement({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/istockphoto.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    child: const Text("Add Customer"),
                    onPressed: () {
                      Navigator.pushNamed(context, '/add_customer');
                    },
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    child: const Text("Customer Details"),
                    onPressed: () {
                      Navigator.pushNamed(context, '/view_customers');
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class ProductManagement extends StatelessWidget {
  const ProductManagement({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/istockphoto.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    child: const Text("Add Product"),
                    onPressed: () {
                      Navigator.pushNamed(context, '/add_product');
                    },
                  ),
                ),
              const  SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    child: const Text("Update Stock"),
                    onPressed: () {
                      Navigator.pushNamed(context, '/stock');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
