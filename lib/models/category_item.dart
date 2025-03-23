import 'package:flutter/material.dart';

class CategoryItem {
  final String name;
  final int amount;
  final IconData icon;
  final Color color;

  CategoryItem({
    required this.name,
    required this.amount,
    required this.icon,
    required this.color,
  });
}
