// lib/models/category_model.dart
import 'package:flutter/material.dart';

class CategoryModel {
  final int? id;
  final String name;
  final String section;
  final IconData icon;
  final Color color;
  int amount;

  CategoryModel({
    this.id,
    required this.name,
    required this.section,
    required this.icon,
    required this.color,
    this.amount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'section': section,
      'icon': icon.codePoint,
      'color': color.value,
    };
  }

  static CategoryModel fromMap(Map<String, dynamic> map, {int amount = 0}) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      section: map['section'],
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
      color: Color(map['color']),
      amount: amount,
    );
  }
}
