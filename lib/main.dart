import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text(
          'Road Sense',
              style: TextStyle(
                  color: Colors.white,
                      fontFamily: 'Inter', fontWeight: FontWeight.bold
              ),
        ),
        backgroundColor: Color(0xFF213448),
        ),
      ),
    ),
  );
}