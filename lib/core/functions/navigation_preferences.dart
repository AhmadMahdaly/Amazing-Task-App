import 'package:flutter/material.dart';
import 'package:s/core/cache_helper/cache_helper.dart';

enum NavItemKey {
  myDay,
  important,
  planned,
  tasks,
  aiTracker,
  challenges,
  islamic,
  notes,
}

class NavigationPreferences {
  static const String _key = 'user_favorite_nav_items';

  static const List<String> defaultItems = [
    'myDay',
    // 'important',
    // 'planned',
    // 'tasks',
  ];

  static final ValueNotifier<List<String>> navItemsNotifier =
      ValueNotifier<List<String>>(defaultItems);

  static Future<void> init() async {
    final rawData = CacheHelper.getData(_key);
    List<String> savedList;

    if (rawData != null && rawData is List) {
      savedList = List<String>.from(rawData);
    } else {
      savedList = List<String>.from(defaultItems);
    }

    if (savedList.isNotEmpty) {
      savedList
        ..remove('myDay')
        ..insert(0, 'myDay');
      navItemsNotifier.value = savedList;
    }
  }

  static Future<bool> saveSelectedItems(List<String> items) async {
    final mutableItems = List<String>.from(items)
      ..remove('myDay')
      ..insert(0, 'myDay');

    if (mutableItems.isEmpty || mutableItems.length > 4) return false;

    final success = await CacheHelper.saveData(key: _key, value: mutableItems);
    if (success) {
      navItemsNotifier.value = mutableItems;
    }
    return success;
  }
}
