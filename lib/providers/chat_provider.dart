import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailmate/models/chat_history.dart';
import 'package:tailmate/models/service_provider_model.dart';
import 'package:tailmate/services/supabase_service.dart';

class ChatProvider extends ChangeNotifier {
  final SupabaseService _supabaseService;
  List<Map<String, dynamic>> _chats = [];
  bool _isLoading = false;
  String? _error;

  ChatProvider(SupabaseClient supabaseClient)
      : _supabaseService = SupabaseService(supabaseClient);

  final List<ChatHistory> _chatHistory = [];

  List<ChatHistory> get chatHistory => List.unmodifiable(_chatHistory);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadChatHistory() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Loading chat history from Supabase...');
      final userId = _supabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      // Get all unique providers from chat history
      final response = await _supabaseService.getChatHistory(userId);
      print('Raw chat history response: $response');

      _chatHistory.clear();
      for (var chat in response) {
        try {
          final providerId = chat['receiver_id'] == userId ? chat['sender_id'] : chat['receiver_id'];
          final provider = await _supabaseService.getServiceProvider(providerId);
          
          _chatHistory.add(
            ChatHistory(
              provider: ServiceProviderModel.fromMap(provider),
              lastMessageTime: DateTime.parse(chat['created_at']),
              lastMessage: chat['message'],
            ),
          );
        } catch (e) {
          print('Error processing chat: $e');
          continue;
        }
      }

      print('Successfully loaded ${_chatHistory.length} chat histories');
    } catch (e) {
      print('Error loading chat history: $e');
      _error = 'Failed to load chat history. Please try again.';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(ServiceProviderModel provider, String message) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Sending message to provider ${provider.id}');
      await _supabaseService.sendMessage(
        receiverId: provider.id,
        message: message,
      );

      // Update local state
      addChat(provider, message);
      print('Message sent successfully');
    } catch (e) {
      print('Error sending message: $e');
      _error = 'Failed to send message. Please try again.';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  Future<void> markMessagesAsRead(String providerId) async {
    try {
      await _supabaseService.markMessagesAsRead(providerId);
      print('Messages marked as read for provider $providerId');
    } catch (e) {
      print('Error marking messages as read: $e');
    }
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