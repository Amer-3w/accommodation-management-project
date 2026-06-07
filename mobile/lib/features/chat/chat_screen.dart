import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  static const route = '/chat';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  int? receiverId;
  Timer? timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)!.settings.arguments as int;
    if (receiverId != id) {
      receiverId = id;
      context.read<ChatProvider>().load(id);
      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (mounted && receiverId != null) context.read<ChatProvider>().load(receiverId!, silent: true);
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final me = context.watch<AuthProvider>().user?.id;
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: chat.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: chat.messages.map((message) {
                      final mine = message.senderId == me;
                      return Align(
                        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: mine ? const Color(0xFF2563EB) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(message.message, style: TextStyle(color: mine ? Colors.white : Colors.black)),
                              const SizedBox(height: 4),
                              Text(mine ? 'Sent' : 'Read', style: TextStyle(color: mine ? Colors.white70 : Colors.black45, fontSize: 10)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Write a message'))),
                  IconButton(
                    onPressed: () async {
                      if (controller.text.trim().isEmpty) return;
                      await context.read<ChatProvider>().send(receiverId!, controller.text.trim());
                      controller.clear();
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
