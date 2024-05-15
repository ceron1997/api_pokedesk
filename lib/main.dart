import 'package:api_pokedesk/view/inicio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // darkTheme: ThemeData.dark(),
       debugShowCheckedModeBanner: false,
      home: Inicio(),
    );
  }
}
