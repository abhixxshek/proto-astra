import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import 'custom_button.dart';

class ResultCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onReset;
  final IconData icon;

  const ResultCard({
    super.key,
    required this.title,
    required this.child,
    required this.onReset,
    this.icon = Icons.check_circle_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          child,
          const SizedBox(height: 20),
          CustomButton(
            text: 'Calculate Again',
            icon: Icons.refresh,
            backgroundColor: AppColors.secondary,
            onPressed: onReset,
          ),
        ],
      ),
    );
  }
}
