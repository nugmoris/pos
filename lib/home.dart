import 'package:flutter/material.dart';

class HomeSalesPage extends StatefulWidget {
  final String varpbuser;
  final String varbagian;
  final String varlks;

  HomeSalesPage(this.varpbuser, this.varbagian, this.varlks);

  @override
  State<HomeSalesPage> createState() => _HomeSalesPageState();
}

class _HomeSalesPageState extends State<HomeSalesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.cable), label: ""),
        ],
      ),
      body: SafeArea(
        child: Text(
          'Hallo ' + widget.varpbuser,
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
