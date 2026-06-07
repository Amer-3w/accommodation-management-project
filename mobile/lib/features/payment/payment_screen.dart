import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/studyhub_design.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../services/payment_service.dart';
import '../../widgets/studyhub_components.dart';
import '../booking/booking_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  static const route = '/payment';

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final formKey = GlobalKey<FormState>();
  final card = TextEditingController();
  final expiry = TextEditingController();
  final cvv = TextEditingController();
  final holder = TextEditingController();
  String method = 'card';
  bool loading = false;
  Booking? booking;
  int? bookingId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (bookingId != null) return;
    final arg = ModalRoute.of(context)!.settings.arguments;
    if (arg is int) {
      bookingId = arg;
      context.read<BookingProvider>().details(arg).then((value) {
        if (mounted) setState(() => booking = value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = booking?.finalTotal ?? 0.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 96),
          children: [
            const Text('Payment Method', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            _MethodTile(icon: Icons.credit_card, title: 'Credit/Debit Card', subtitle: 'Pay securely with your card', selected: method == 'card', onTap: () => setState(() => method = 'card')),
            const SizedBox(height: 10),
            _MethodTile(icon: Icons.payments_outlined, title: 'Cash Payment', subtitle: 'Pay with cash on arrival', selected: method == 'cash', onTap: () => setState(() => method = 'cash')),
            const SizedBox(height: 18),
            if (method == 'card') ...[
              StudyHubTextField(controller: card, label: 'Card Number', hint: '1234 5678 9012 3456', keyboardType: TextInputType.number, validator: (v) => RegExp(r'^\d{16}$').hasMatch((v ?? '').replaceAll(' ', '')) ? null : 'Enter a 16 digit card number'),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: StudyHubTextField(controller: expiry, label: 'Expiry Date', hint: 'MM/YY', validator: (v) => RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(v ?? '') ? null : 'Use MM/YY')),
                const SizedBox(width: 12),
                Expanded(child: StudyHubTextField(controller: cvv, label: 'CVV', hint: '123', keyboardType: TextInputType.number, validator: (v) => RegExp(r'^\d{3,4}$').hasMatch(v ?? '') ? null : 'Invalid CVV')),
              ]),
              const SizedBox(height: 14),
              StudyHubTextField(controller: holder, label: 'Cardholder Name', hint: 'Name on card', validator: (v) => (v ?? '').trim().length >= 3 ? null : 'Enter cardholder name'),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF7F8FA), borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Payment Summary', style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                _SummaryRow(label: 'Base total (${booking?.numberOfDays ?? 0} days)', value: '\$${(booking?.baseTotal ?? 0).toStringAsFixed(2)}'),
                _SummaryRow(label: 'Discount (${(booking?.discountPercent ?? 0).toStringAsFixed(0)}%)', value: '-\$${(booking?.discountAmount ?? 0).toStringAsFixed(2)}'),
                _SummaryRow(label: 'Security deposit', value: '\$${(booking?.securityDeposit ?? 0).toStringAsFixed(2)}'),
                _SummaryRow(label: 'Service fee', value: '\$${(booking?.serviceFee ?? 0).toStringAsFixed(2)}'),
                const Divider(),
                _SummaryRow(label: 'Total Amount', value: '\$${total.toStringAsFixed(2)}', strong: true),
              ]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(18),
        child: StudyHubPrimaryButton(
          label: booking == null ? 'Loading...' : 'Pay \$${total.toStringAsFixed(2)}',
          color: StudyHubColors.success,
          loading: loading,
          onPressed: () async {
            if (method == 'card' && !formKey.currentState!.validate()) return;
            if (bookingId == null || booking == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking total is still loading. Please try again.')));
              return;
            }
            setState(() => loading = true);
            try {
              await context.read<PaymentService>().pay(bookingId: bookingId!, method: method);
              if (context.mounted) Navigator.pushReplacementNamed(context, BookingSuccessScreen.route);
            } finally {
              if (mounted) setState(() => loading = false);
            }
          },
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({required this.icon, required this.title, required this.subtitle, required this.selected, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: selected ? StudyHubColors.softGreen : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: selected ? StudyHubColors.darkGreen : StudyHubColors.line)),
        child: Row(children: [
          CircleAvatar(backgroundColor: selected ? StudyHubColors.darkGreen : const Color(0xFFF3F4F6), child: Icon(icon, color: selected ? Colors.white : StudyHubColors.secondaryText)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(subtitle, style: const TextStyle(color: StudyHubColors.secondaryText, fontSize: 12)),
          ]),
        ]),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.strong = false});
  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Text(label, style: TextStyle(fontWeight: strong ? FontWeight.w900 : FontWeight.w500)),
        const Spacer(),
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: strong ? 19 : 13, color: strong ? StudyHubColors.darkGreen : StudyHubColors.text)),
      ]),
    );
  }
}
