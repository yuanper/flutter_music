import 'package:flutter/material.dart';
import 'package:flutter_music/pages/home_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  createState() => new  MyAppState();
}

class MyAppState extends State<MyApp> {
  @override 
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: ThemeData(primaryColor: Colors.blue),
      home: new HomePage(),
    );
  }
}