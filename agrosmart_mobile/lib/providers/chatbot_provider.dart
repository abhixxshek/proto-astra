import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/models/chat_message_model.dart';

class ChatBotProvider extends ChangeNotifier {
  final List<ChatMessageModel> _messages = [
    ChatMessageModel(
      text: "Namaste Farmer! 🌾 I am your AgroSmart AI Farming Assistant. Ask me anything about soil testing, crop diseases, fertilizers, MSP rates, sowing seasons, or weather!",
      isUser: false,
    ),
  ];

  bool _isTyping = false;

  List<ChatMessageModel> get messages => _messages;
  bool get isTyping => _isTyping;

  Future<void> sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    _messages.add(ChatMessageModel(text: query, isUser: true));
    _isTyping = true;
    notifyListeners();

    try {
      final reply = await _getAiReply(query);
      _messages.add(ChatMessageModel(text: reply, isUser: false));
    } catch (_) {
      _messages.add(ChatMessageModel(
        text: "I am having trouble connecting right now, but please verify your soil profile using AgroSmart Soil Report Intelligence for detailed agronomic guidance!",
        isUser: false,
      ));
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  Future<String> _getAiReply(String userMessage) async {
    final lower = userMessage.toLowerCase();

    // 1. Try BrainShop AI endpoint
    try {
      final cleanMsg = Uri.encodeComponent(userMessage);
      final url = Uri.parse("http://api.brainshop.ai/get?bid=174019&key=HC5OGdHhUQPzfMOy&uid=1&msg=$cleanMsg");
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['cnt'] != null && data['cnt'].toString().trim().isNotEmpty) {
          return data['cnt'].toString();
        }
      }
    } catch (_) {}

    // 2. Intelligent Agricultural Fallback Logic
    if (lower.contains('soil') || lower.contains('मिट्टी') || lower.contains('report') || lower.contains('npk')) {
      return "You can upload your Soil Test PDF in the 'Soil Report Intelligence' feature. AgroSmart extracts NPK, pH, and micronutrients automatically and predicts suitable crops, yield, and fertilizers!";
    } else if (lower.contains('wheat') || lower.contains('गेहूं')) {
      return "For Wheat cultivation, ensure sowing between Nov 15-30. Recommended seed rate is 100 kg/ha. Apply CRI irrigation at 21 days after sowing. Soil pH should ideally be 6.0-7.5.";
    } else if (lower.contains('fertilizer') || lower.contains('खाद') || lower.contains('urea')) {
      return "Apply balanced NPK fertilizer based on your verified Soil Report Card. Neem-coated Urea is recommended in 3 split doses (at sowing, first irrigation, and tillering).";
    } else if (lower.contains('disease') || lower.contains('leaf') || lower.contains('रोग') || lower.contains('बीमारी')) {
      return "Use the 'Plant Disease Detection' tool in AgroSmart to snap a photo of the affected leaf! The PyTorch model detects 39 plant diseases and provides organic & chemical treatments.";
    } else if (lower.contains('price') || lower.contains('mandi') || lower.contains('भाव')) {
      return "Check out the APMC Mandi Market Prices section in AgroSmart to view daily commodity spot rates across mandis in India!";
    } else if (lower.contains('water') || lower.contains('irrigation') || lower.contains('सिंचाई')) {
      return "Drip irrigation increases water use efficiency up to 90%. Avoid over-irrigation during flowering to prevent root rot and flower drop.";
    }

    return "For best crop yields, upload your Soil Test Report PDF in AgroSmart or check our APMC Mandi Prices and Disease Detection tools!";
  }

  void clearChat() {
    _messages.clear();
    _messages.add(ChatMessageModel(
      text: "Chat cleared! How can I assist your farm today?",
      isUser: false,
    ));
    notifyListeners();
  }
}
