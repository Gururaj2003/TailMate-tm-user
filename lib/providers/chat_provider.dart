import 'package:flutter/foundation.dart';
import 'package:tailmate/models/chat_history.dart';
import 'package:tailmate/models/service_provider_model.dart';

class ChatProvider with ChangeNotifier {
  final List<ChatHistory> _chatHistory = [];

  List<ChatHistory> get chatHistory => List.unmodifiable(_chatHistory);

  void addChat(ServiceProviderModel provider, String message) {
    final existingIndex = _chatHistory.indexWhere(
      (chat) => chat.provider.id == provider.id,
    );

    if (existingIndex >= 0) {
      _chatHistory[existingIndex] = ChatHistory(
        provider: provider,
        lastMessageTime: DateTime.now(),
        lastMessage: message,
      );
    } else {
      _chatHistory.add(
        ChatHistory(
          provider: provider,
          lastMessageTime: DateTime.now(),
          lastMessage: message,
        ),
      );
    }
    notifyListeners();
  }

  void removeChat(String providerId) {
    _chatHistory.removeWhere((chat) => chat.provider.id == providerId);
    notifyListeners();
  }

  ChatHistory? getChatByProviderId(String providerId) {
    try {
      return _chatHistory.firstWhere(
        (chat) => chat.provider.id == providerId,
      );
    } catch (e) {
      return null;
    }
  }
} 