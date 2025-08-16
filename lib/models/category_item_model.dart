import 'package:flutter/material.dart';

import '../enums/category_type.dart';

class CategoryItem {
  CategoryItem({
    required this.title,
    required this.description,
    required this.type,
    required this.icon,
  });

  final String title;
  final String description;
  final CategoryType type;
  final IconData icon;
}
