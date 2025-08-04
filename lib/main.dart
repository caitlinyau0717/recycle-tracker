import 'package:flutter/material.dart';
import 'package:recycletracker/pages/create_account.dart'; // Import the new page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CreateAccountPage(), // Set as home page
    );
  }
}
