import 'package:flutter/material.dart';

/// Lazy loading list builder widget'i
/// Katta ro'yxatlarni optimallashtirish uchun
class LazyListBuilder<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final int? itemCount;

  const LazyListBuilder({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.padding,
    this.physics,
    this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      physics: physics,
      itemCount: itemCount ?? items.length,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, items[index], index),
        );
      },
    );
  }
}

