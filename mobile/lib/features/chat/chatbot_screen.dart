import 'package:flutter/material.dart';

import '../../core/theme/studyhub_design.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});
  static const route = '/chatbot';

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final input = TextEditingController();
  final messages = <(bool, String)>[(false, 'Hi, I can help you find properties, book rooms, contact owners, or reach support.')];

  void send() {
    final text = input.text.trim();
    if (text.isEmpty) return;
    input.clear();
    final lower = text.toLowerCase();
    final answer = lower.contains('book')
        ? 'Open a property and tap Book Now, or go to My Bookings to manage requests.'
        : lower.contains('owner') || lower.contains('chat')
            ? 'Use the Chat button on a property or owner profile to message the owner.'
            : lower.contains('payment')
                ? 'Payments are sandboxed. Enter valid card details to create a test payment.'
                : lower.contains('support')
                    ? 'Open Help & Support to contact admin by message or WhatsApp.'
                    : 'Try asking about bookings, payments, chat, properties, or support.';
    setState(() {
      messages.add((true, text));
      messages.add((false, answer));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('StudyHub Assistant')),
        body: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: messages
                  .map((message) => Align(
                        alignment: message.$1 ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: message.$1 ? StudyHubColors.darkGreen : Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: StudyHubShadows.soft),
                          child: Text(message.$2, style: TextStyle(color: message.$1 ? Colors.white : StudyHubColors.text)),
                        ),
                      ))
                  .toList(),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Expanded(child: TextField(controller: input, decoration: const InputDecoration(hintText: 'Ask about StudyHub...'))),
                IconButton(onPressed: send, icon: const Icon(Icons.send)),
              ]),
            ),
          ),
        ]),
      );
}
