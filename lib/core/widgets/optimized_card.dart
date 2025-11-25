import 'package:flutter/material.dart';

/// Optimallashtirilgan card widget'i
/// RepaintBoundary va const optimallashtirishlar bilan
class OptimizedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final VoidCallback? onTap;

  const OptimizedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.decoration,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: child,
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: decoration is BoxDecoration &&
                  (decoration as BoxDecoration).borderRadius != null
              ? (decoration as BoxDecoration).borderRadius as BorderRadius?
              : null,
          child: card,
        ),
      );
    }

    return RepaintBoundary(child: card);
  }
}

