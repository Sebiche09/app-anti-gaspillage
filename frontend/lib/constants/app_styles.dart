import 'package:flutter/material.dart';
import 'app_colors.dart';

// ce fichier contient les styles de texte et les décorations d'interface utilisateur utilisés dans l'application
class AppStyles {
  static const TextStyle titleStyle = TextStyle(
    color: Colors.black,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    fontFamily: 'Righteous',
     
  );
  
  static const TextStyle subtitleStyle = TextStyle(
    color: Colors.grey,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: 'Manrope',
  );

  static InputDecoration textFieldDecoration(String hintText, IconData prefixIcon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hintText,
      prefixIcon: Icon(prefixIcon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
