import 'package:flutter/material.dart';
import 'glass_text_field.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final String? suffixText;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return GlassTextField(
      controller: controller,
      label: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffix: suffixText != null
          ? Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                widthFactor: 1.0,
                child: Text(
                  suffixText!,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black54),
                ),
              ),
            )
          : null,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
    );
  }
}
