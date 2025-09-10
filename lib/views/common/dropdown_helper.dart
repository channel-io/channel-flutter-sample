import 'package:flutter/material.dart';

/// DropdownMenuItem creation helper utility
class DropdownHelper {
  /// Create DropdownMenuItem from simple string list
  static List<DropdownMenuItem<String>> buildStringItems(List<String> values) {
    return values
        .map((value) => DropdownMenuItem(value: value, child: Text(value)))
        .toList();
  }

  /// Create DropdownMenuItem from Map (value: display text)
  static List<DropdownMenuItem<String>> buildMapItems(
    Map<String, String> items,
  ) {
    return items.entries
        .map(
          (entry) =>
              DropdownMenuItem(value: entry.key, child: Text(entry.value)),
        )
        .toList();
  }

  /// Create DropdownMenuItem using custom widget
  static List<DropdownMenuItem<String>> buildCustomItems(
    Map<String, Widget> items,
  ) {
    return items.entries
        .map((entry) => DropdownMenuItem(value: entry.key, child: entry.value))
        .toList();
  }
}
