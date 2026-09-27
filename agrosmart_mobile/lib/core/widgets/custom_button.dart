import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import 'glass_button.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double width;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return GlassButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      width: width,
      customColor: backgroundColor ?? AppColors.primary,
      variant: GlassButtonVariant.primary,
    );
  }
}
