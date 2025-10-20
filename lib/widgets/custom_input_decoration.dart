import 'package:flutter/material.dart';

InputDecoration customInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
      color: Colors.black54,
      fontSize: 14,
    ),
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(
        color: Color(0xFFCCCCCC),
        width: 1.5,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(
        width: 2,
        color: Color(0xFF5E60CE),
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  );
}
