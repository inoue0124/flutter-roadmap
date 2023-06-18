import 'package:flutter/material.dart';
import 'package:graph/roadmap_widget.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Roadmap Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: RoadMapWidget(
          onSelectNode: (node) => print(node.value),
        ));
  }
}
