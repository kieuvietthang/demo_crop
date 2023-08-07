import 'package:flutter/material.dart';
import 'package:untitled/image_selector.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter demo",
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: ImageChecker(),
    );
  }
}
