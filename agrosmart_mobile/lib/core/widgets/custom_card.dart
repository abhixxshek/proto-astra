import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_glass.dart';
import 'glass_card.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Border? border;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.onTap,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: padding,
      fillColor: color ?? AppColors.glassFillCard,
      onTap: onTap,
      borderRadius: borderRadius ?? AppGlass.borderRadiusLg,
      border: border,
      child: child,
    );
  }
}
