import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/EduStay_design.dart';

class OwnerPaymentsScreen extends StatefulWidget {
  const OwnerPaymentsScreen({super.key});
  @override
  State<OwnerPaymentsScreen> createState() => _OwnerPaymentsScreenState();
}

class _OwnerPaymentsScreenState extends State<OwnerPaymentsScreen> {
  bool loading = true;
  List<dynamic> payments = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final response = await context.read<ApiClient>().get('/owner/payments');
    if (mounted) {
      setState(() {
        payments = (response['data'] as List<dynamic>?) ?? [];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Payments')),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : payments.isEmpty
                ? const Center(
                    child: Text('No payments received.',
                        style: TextStyle(color: EduStayColors.secondaryText)))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(18),
                      itemCount: payments.length,
                      itemBuilder: (_, i) {
                        final p = payments[i] as Map<String, dynamic>;
                        final booking =
                            p['booking'] as Map<String, dynamic>?;
                        final property =
                            booking?['property'] as Map<String, dynamic>?;
                        final user =
                            booking?['user'] as Map<String, dynamic>?;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        property?['title']?.toString() ??
                                            'Property',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w900)),
                                    const SizedBox(height: 4),
                                    Text(
                                        'Tenant: ${user?['name'] ?? user?['email'] ?? 'Unknown'}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: EduStayColors
                                                .secondaryText)),
                                    Text(
                                        '${p['method']} - ${p['status'] ?? 'pending'}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: EduStayColors
                                                .secondaryText)),
                                  ],
                                ),
                              ),
                              Text('\$${p['amount'] ?? 0}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      color: EduStayColors.darkGreen)),
                            ]),
                          ),
                        );
                      },
                    ),
                  ),
      );
}