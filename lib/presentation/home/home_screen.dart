import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: Center(
        child: Text(
          'Home',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
