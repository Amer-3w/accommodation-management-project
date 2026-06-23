import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/EduStay_design.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});
  static const route = '/payment-history';

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  bool loading = true;
  List<dynamic> rows = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final response = await context.read<ApiClient>().get('/payments');
    if (mounted) {
      setState(() {
        rows = response['data']['data'] as List<dynamic>;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Payment History')),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : rows.isEmpty
                ? const Center(
                    child: Text('No payments yet.',
                        style: TextStyle(color: EduStayColors.secondaryText)))
                : ListView.separated(
                    padding: const EdgeInsets.all(18),
                    itemBuilder: (_, index) {
                      final row = rows[index] as Map<String, dynamic>;
                      final booking = row['booking'] as Map<String, dynamic>?;
                      final property =
                          booking?['property'] as Map<String, dynamic>?;
                      return ListTile(
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        title: Text(
                            property?['title']?.toString() ?? 'Property',
                            style:
                                const TextStyle(fontWeight: FontWeight.w900)),
                        subtitle: Text(
                            '${row['method']} - ${row['status']} - ${row['created_at'] ?? ''}'),
                        trailing: Text('\$${row['amount']}',
                            style: const TextStyle(
                                color: EduStayColors.darkGreen,
                                fontWeight: FontWeight.w900)),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemCount: rows.length,
                  ),
      );
}
