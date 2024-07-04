import 'package:flutter/material.dart';
import 'package:umkm/homepage.dart';
import 'package:umkm/umkm.dart';

import 'admin.dart';
import 'login.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/admin_home': (context) => const AdminHomePage(),
        '/umkm_home': (context) => const UmkmPage(),
      },
    );
  }
}
