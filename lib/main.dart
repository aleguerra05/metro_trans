import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'TransactView.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'MetroTrans',
      home: new TransactView(),
    );
  }
}