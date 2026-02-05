import 'package:flutter/material.dart';

// Helper to apply opacity without using the deprecated `withOpacity` API.
Color withOpacityColor(Color base, double opacity) {
  final int r = base.red;
  final int g = base.green;
  final int b = base.blue;
  return Color.fromRGBO(r, g, b, opacity);
}
