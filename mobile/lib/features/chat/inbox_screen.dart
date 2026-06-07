import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/studyhub_design.dart';
import '../../providers/chat_provider.dart';
import 'chat_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});
  static const route = '/inbox';

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  bool loading = true;
  List<dynamic> conversations = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final response = await context.read<ChatProvider>().conversations();
    if (mounted) setState(() { conversations = response; loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : conversations.isEmpty
              ? const Center(child: Text('No conversations yet.'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(18),
                    itemBuilder: (_, index) {
                      final item = conversations[index] as Map<String, dynamic>;
                      final name = item['name']?.toString() ?? 'User';
                      final unread = int.tryParse('${item['unread_count'] ?? 0}') ?? 0;
                      return ListTile(
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        leading: CircleAvatar(backgroundColor: StudyHubColors.darkGreen, child: Text(name.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white))),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
                        subtitle: Text(item['last_message']?.toString() ?? ''),
                        trailing: unread > 0 ? CircleAvatar(radius: 11, backgroundColor: StudyHubColors.error, child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10))) : const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(context, ChatScreen.route, arguments: item['user_id']).then((_) => _load()),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemCount: conversations.length,
                  ),
                ),
    );
  }
}
