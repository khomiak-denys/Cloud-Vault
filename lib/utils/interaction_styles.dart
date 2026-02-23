import 'package:flutter/material.dart';

WidgetStateProperty<Color?> pressOnlyOverlay(Color color) {
  return WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.pressed)) {
      return color;
    }
    return Colors.transparent;
  });
}
