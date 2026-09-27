import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_text_field.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendFeedback() {
    if (_messageController.text.trim().isNotEmpty) {
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you! Your message has been submitted to AgroSmart support.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      drawer: const AppDrawer(currentRoute: AppRoutes.help),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How can we help you?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Browse FAQs or reach out to our agricultural expert advisory team.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // FAQ Accordions
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            _buildFaqItem(
              'How does AgroSmart recommend crops?',
              'Our system processes 7 core environmental factors (Nitrogen, Phosphorus, Potassium, Temperature, Humidity, Soil pH, and Rainfall) through a Random Forest Classifier model trained on thousands of agricultural soil samples.',
            ),
            _buildFaqItem(
              'When should I apply fertilizers based on weather forecast?',
              'Always avoid applying fertilizers if rainfall is expected within 24-48 hours. Rainfall causes nutrient runoff into groundwater. Apply fertilizers during clear, calm weather.',
            ),
            _buildFaqItem(
              'What units are used for Yield Prediction?',
              'Yield is measured in hg/ha (hectograms per hectare). 10,000 hg/ha is equivalent to 1 metric tonne per hectare.',
            ),

            const SizedBox(height: 24),

            // Contact Us Card
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Submit Advisory Query',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _messageController,
                    label: 'Describe your query or feedback',
                    hint: 'Type your message here...',
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Send Support Request',
                    icon: Icons.send_rounded,
                    onPressed: _sendFeedback,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return CustomCard(
      padding: const EdgeInsets.all(0),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
