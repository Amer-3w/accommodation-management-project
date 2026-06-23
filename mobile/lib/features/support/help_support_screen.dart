import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/EduStay_design.dart';
import '../../core/utils/json_parsers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/EduStay_components.dart';
import '../chat/chat_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});
  static const route = '/help-support';

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final subject = TextEditingController();
  final message = TextEditingController();
  bool sending = false;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final faqs = const [
      (
        'How do I book a property?',
        'Open a property, tap Book Now, choose dates and guests, then submit the booking.'
      ),
      (
        'How do I contact an owner?',
        'Use Chat on the property details page or open the owner profile and tap Chat.'
      ),
      (
        'Can I cancel a booking?',
        'Yes. Open My Bookings and use Cancel on eligible bookings.'
      ),
      (
        'How do payments work?',
        'Payments are sandboxed. Valid card details create a payment record for testing.'
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: EduStayShadows.soft),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('FAQ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              ...faqs.map((faq) => ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(faq.$1,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      children: [
                        Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(faq.$2))),
                      ])),
            ]),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: _openWhatsApp,
                    icon: const Icon(Icons.call_outlined),
                    label: const Text('WhatsApp'))),
            const SizedBox(width: 10),
            Expanded(
                child: ElevatedButton.icon(
                    onPressed: _chatAdmin,
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Chat Admin'))),
          ]),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: EduStayShadows.soft),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Send Support Message',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(
                  'From: ${user?.email?.isNotEmpty == true ? user!.email : user?.phone ?? 'Authenticated account'}',
                  style: const TextStyle(
                      color: EduStayColors.secondaryText, fontSize: 12)),
              const SizedBox(height: 12),
              EduStayTextField(
                  controller: subject,
                  label: 'Subject',
                  hint: 'What do you need help with?',
                  validator: _required),
              const SizedBox(height: 12),
              EduStayTextField(
                  controller: message,
                  label: 'Message',
                  hint: 'Describe the issue',
                  maxLines: 5,
                  validator: _required),
              const SizedBox(height: 14),
              EduStayPrimaryButton(
                  label: 'Send Message',
                  loading: sending,
                  onPressed: _sendSupport),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/972599776965');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp.')));
    }
  }

  Future<void> _chatAdmin() async {
    final response =
        await context.read<ApiClient>().get('/support/admin-contact');
    final adminId = parseInt(response['data']['id']);
    if (adminId == 0) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin chat is not available yet.')));
      return;
    }
    if (mounted)
      Navigator.pushNamed(context, ChatScreen.route, arguments: adminId);
  }

  Future<void> _sendSupport() async {
    if (subject.text.trim().isEmpty || message.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subject and message are required.')));
      return;
    }
    setState(() => sending = true);
    try {
      await context.read<ApiClient>().post('/support/messages', {
        'name': 'Student',
        'email': 'student@example.com',
        'phone': '123456789',
        'subject': subject.text.trim(),
        'message': message.text.trim(),
      });
      subject.clear();
      message.clear();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Support message sent.')));
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;
}
