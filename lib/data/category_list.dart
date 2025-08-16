import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../enums/category_type.dart';
import '../models/category_item_model.dart';

final List<CategoryItem> categoryList = [
  CategoryItem(
    title: "Greetings",
    description: "Common ways to say hello and goodbye.",
    type: CategoryType.grettings,
    icon: PhosphorIconsRegular.handWaving,
  ),
  CategoryItem(
    title: "Socialize",
    description: "Phrases for meeting and talking to people.",
    type: CategoryType.socialize,
    icon: PhosphorIconsRegular.usersThree,
  ),
  CategoryItem(
    title: "Directions",
    description: "How to ask for and give directions?",
    type: CategoryType.directions,
    icon: PhosphorIconsRegular.mapPin,
  ),
  CategoryItem(
    title: "Swearings",
    description: "Slang and strong language expressions.",
    type: CategoryType.swearings,
    icon: PhosphorIconsRegular.warning,
  ),
  CategoryItem(
    title: "Food",
    description: "Ordering and talking about food and drinks.",
    type: CategoryType.food,
    icon: PhosphorIconsRegular.forkKnife,
  ),
];
