import 'package:flutter/material.dart';

/// Optimallashtirilgan container widget'i
/// RepaintBoundary bilan o'ralgan container
class OptimizedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  const OptimizedContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.decoration,
    this.width,
    this.height,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: padding,
        margin: margin,
        decoration: decoration,
        width: width,
        height: height,
        alignment: alignment,
        child: child,
      ),
    );
  }
}
