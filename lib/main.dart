import 'package:flutter/material.dart';
import 'package:recycletracker/pages/login_page.dart'; 
import 'package:provider/provider.dart';
import 'pages/interPageComms.dart';
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
void main() {
    runApp(
    ChangeNotifierProvider(
      create: (_) => UserData(), 
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      navigatorObservers: [routeObserver],
    );
  }
}
