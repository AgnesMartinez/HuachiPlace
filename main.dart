import 'package:flutter/material.dart';
import 'grid.dart';
import 'placecolors.dart';

//Entry point 
void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    //Boilerplate code for main app
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HuachiPlace',
      home: HuachiPlace()
    );
  }
}

class HuachiPlace extends StatefulWidget {
  const HuachiPlace({Key? key}) : super(key: key);
  
  @override
  State<HuachiPlace> createState() => _HuachiPlaceState();
}

class _HuachiPlaceState extends State<HuachiPlace> {

  @override
  Widget build(BuildContext context) {

    //Add the GridManager to the Scaffold Widget
    return const Scaffold(
      backgroundColor: PlaceColors.primaryBackground,
      body: Center(
        child: GridManager()
      )
    );
  }
}
