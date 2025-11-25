import 'package:flutter/material.dart';

/// Performance utility funksiyalari
class PerformanceUtils {
  /// Widget'ni RepaintBoundary bilan o'rash
  static Widget wrapWithRepaintBoundary(Widget child) {
    return RepaintBoundary(child: child);
  }

  /// Const SizedBox yaratish
  static const SizedBox sizedBox4 = SizedBox(height: 4);
  static const SizedBox sizedBox8 = SizedBox(height: 8);
  static const SizedBox sizedBox12 = SizedBox(height: 12);
  static const SizedBox sizedBox16 = SizedBox(height: 16);
  static const SizedBox sizedBox20 = SizedBox(height: 20);
  static const SizedBox sizedBox24 = SizedBox(height: 24);
  static const SizedBox sizedBox32 = SizedBox(height: 32);

  /// Const SizedBox width
  static const SizedBox sizedBoxWidth4 = SizedBox(width: 4);
  static const SizedBox sizedBoxWidth8 = SizedBox(width: 8);
  static const SizedBox sizedBoxWidth12 = SizedBox(width: 12);
  static const SizedBox sizedBoxWidth16 = SizedBox(width: 16);
  static const SizedBox sizedBoxWidth20 = SizedBox(width: 20);
}

