import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/EduStay_design.dart';
import '../chat/inbox_screen.dart';

class OwnerTenantsScreen extends StatefulWidget {
  const OwnerTenantsScreen({super.key});
  @override
  State<OwnerTenantsScreen> createState() => _OwnerTenantsScreenState();
}

class _OwnerTenantsScreenState extends State<OwnerTenantsScreen> {
  bool loading = true;
  List<dynamic> tenants = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final response = await context.read<ApiClient>().get('/owner/tenants');
    if (mounted) {
      setState(() {
        tenants = (response['data'] as List<dynamic>?) ?? [];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Tenants')),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : tenants.isEmpty
                ? const Center(
                    child: Text('No active tenants.',
                        style: TextStyle(color: EduStayColors.secondaryText)))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(18),
                      itemCount: tenants.length,
                      itemBuilder: (_, i) {
                        final t = tenants[i] as Map<String, dynamic>;
                        final name = t['name']?.toString() ?? 'Tenant';
                        final email = t['email']?.toString() ?? '';
                        final id = t['id'];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: EduStayColors.softGreen,
                              child: Text(
                                name[0].toUpperCase(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900)),
                            ),
                            title: Text(name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900)),
                            subtitle: Text(email,
                                style: const TextStyle(
                                    color: EduStayColors.secondaryText,
                                    fontSize: 12)),
                            trailing: IconButton(
                              icon: const Icon(Icons.chat_bubble_outline,
                                  color: EduStayColors.darkGreen),
                              onPressed: () => Navigator.pushNamed(
                                  context, InboxScreen.route,
                                  arguments: {
                                    'user_id': id,
                                    'name': name
                                  }),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      );
}