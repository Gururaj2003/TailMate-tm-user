import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailmate/providers/chat_provider.dart';
import 'package:tailmate/screens/chat_screen.dart';
import 'package:intl/intl.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final chatHistory = chatProvider.chatHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: chatHistory.isEmpty
          ? const Center(
              child: Text('No chats yet'),
            )
          : ListView.builder(
              itemCount: chatHistory.length,
              itemBuilder: (context, index) {
                final chat = chatHistory[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: chat.provider.imageUrl != null
                        ? NetworkImage(chat.provider.imageUrl!)
                        : null,
                    child: chat.provider.imageUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(chat.provider.name),
                  subtitle: Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    DateFormat('MMM d, h:mm a').format(chat.lastMessageTime),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          provider: chat.provider,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
} 