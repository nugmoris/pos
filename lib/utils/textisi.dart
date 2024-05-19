import 'package:flutter/material.dart';

class TextIsi extends StatelessWidget {
  final controller;
  final String hintText;
  final String labeltextku;
  final bool obsecuretext;

  const TextIsi(
      {required this.controller,
      required this.hintText,
      required this.labeltextku,
      required this.obsecuretext,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        controller: controller,
        obscureText: obsecuretext,
        decoration: InputDecoration(
            labelText: labeltextku,
            hintText: hintText,
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue.shade700),
            ),
            fillColor: Colors.grey.shade200,
            filled: true,
            hintStyle: TextStyle(color: Colors.grey[500])),
      ),
    );
  }
}
