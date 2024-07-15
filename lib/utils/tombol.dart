import 'package:flutter/material.dart';

class TombolWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  TombolWidget({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(icon, size: 40, color: Colors.blue[700]),
                Text(text, style: TextStyle(color: Colors.blue[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
