import 'package:flutter/material.dart';

import 'login.dart' show LoginPage;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ArtTime',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
        ),
        home: const Scaffold(
          body: LoginPage(),
        ));
  }
}
