import 'package:flutter/material.dart';

class CardTemplate {
  final String id;
  final String name;
  final Color defaultTextColor;
  final Color primaryColor;
  final Color backgroundColor;
  final String? backgroundImageUrl;

  const CardTemplate({
    required this.id,
    required this.name,
    required this.defaultTextColor,
    required this.primaryColor,
    required this.backgroundColor,
    this.backgroundImageUrl,
  });

  static const templates = [
    CardTemplate(
      id: 'classic',
      name: 'Classic',
      defaultTextColor: Color(0xFF1D1D1D),
      primaryColor: Color(0xFF6A3EEB),
      backgroundColor: Colors.white,
    ),
    CardTemplate(
      id: 'dark_pro',
      name: 'Dark Pro',
      defaultTextColor: Colors.white,
      primaryColor: Color(0xFF6A3EEB),
      backgroundColor: Color(0xFF1A1A2E),
    ),
    CardTemplate(
      id: 'gradient',
      name: 'Gradient Card',
      defaultTextColor: Colors.white,
      primaryColor: Color(0xFFEDE8FC),
      backgroundColor: Color(0xFF6A3EEB),
    ),
    CardTemplate(
      id: 'cream',
      name: 'Minimal Cream',
      defaultTextColor: Color(0xFF2C2C2C),
      primaryColor: Color(0xFF6A3EEB),
      backgroundColor: Color(0xFFFAF7F2),
    ),
    CardTemplate(
      id: 'split',
      name: 'Bold Split',
      defaultTextColor: Color(0xFF1D1D1D),
      primaryColor: Color(0xFF6A3EEB),
      backgroundColor: Colors.white,
    ),
    CardTemplate(
      id: 'blue_gradient',
      name: 'Blue Gradient',
      defaultTextColor: Colors.white,
      primaryColor: Colors.blue,
      backgroundColor: Colors.blueAccent,
      backgroundImageUrl: 'https://zsjinlmpmbxkjghxhoqh.supabase.co/storage/v1/object/public/card-images/Blue%20Gradient%20Creative%20Business%20Card.jpg',
    ),
    CardTemplate(
      id: 'red_gradient',
      name: 'Red Gradient',
      defaultTextColor: Colors.white,
      primaryColor: Colors.red,
      backgroundColor: Colors.redAccent,
      backgroundImageUrl: 'https://zsjinlmpmbxkjghxhoqh.supabase.co/storage/v1/object/public/card-images/Red%20Gradient%20Creative%20Business%20Card.png',
    ),
    CardTemplate(
      id: 'simple_corporate',
      name: 'Simple Corporate',
      defaultTextColor: Color(0xFF1A1A1A),
      primaryColor: Color(0xFF0056B3),
      backgroundColor: Colors.white,
      backgroundImageUrl: 'https://zsjinlmpmbxkjghxhoqh.supabase.co/storage/v1/object/public/card-images/Simple%20Corporate%20Business%20Card.jpg',
    ),
    CardTemplate(
      id: 'fire',
      name: 'Orange Fire',
      defaultTextColor: Color(0xFF1D1D1D),
      primaryColor: Color(0xFFE03000),
      backgroundColor: Colors.white,
    ),
  ];
}
