import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
       actions: [
        IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
          
            Navigator.pushNamed(context, '/'); 
          },
        ),
      ],
    );  
    
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

