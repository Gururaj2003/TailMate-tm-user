import 'package:tailmate/models/service_provider_model.dart';

class ChatHistory {
  final ServiceProviderModel provider;
  final DateTime lastMessageTime;
  final String lastMessage;

  ChatHistory({
    required this.provider,
    required this.lastMessageTime,
    required this.lastMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'provider': provider.toMap(),
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'lastMessage': lastMessage,
    };
  }

  factory ChatHistory.fromMap(Map<String, dynamic> map) {
    return ChatHistory(
      provider: ServiceProviderModel.fromMap(map['provider']),
      lastMessageTime: DateTime.parse(map['lastMessageTime']),
      lastMessage: map['lastMessage'],
    );
  }
} 