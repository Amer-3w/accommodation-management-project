import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/EduStay_design.dart';
import '../../providers/booking_provider.dart';
import '../../services/payment_service.dart';
import '../../widgets/EduStay_components.dart';
import '../shell/EduStay_shell.dart';

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
  int? bookingId;
  double amount = 0.0;
  double baseTotal = 0.0;
  double deposit = 0.0;
  double serviceFee = 0.0;
  double discountPct = 0.0;
  double discountAmt = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (bookingId != null) return;
    final arg = ModalRoute.of(context)!.settings.arguments;
    if (arg is Map && arg['bookingId'] is int) {
      bookingId = arg['bookingId'] as int;
      final a = arg['amount'];
      if (a is double) amount = a;
      else if (a is int) amount = a.toDouble();
      else if (a is String) amount = double.tryParse(a) ?? 0.0;
      baseTotal = (arg['baseTotal'] as num?)?.toDouble() ?? 0.0;
      deposit = (arg['deposit'] as num?)?.toDouble() ?? 100.0;
      serviceFee = (arg['serviceFee'] as num?)?.toDouble() ?? 0.0;
      discountPct = (arg['discountPct'] as num?)?.toDouble() ?? 0.0;
      discountAmt = (arg['discountAmt'] as num?)?.toDouble() ?? 0.0;
    } else if (arg is int) {
      bookingId = arg;
      context.read<BookingProvider>().details(arg).then((b) {
        if (mounted) setState(() {
          amount = b.finalTotal > 0 ? b.finalTotal : b.baseTotal + b.securityDeposit;
          baseTotal = b.baseTotal;
          deposit = b.securityDeposit;
          serviceFee = b.serviceFee;
          discountPct = b.discountPercent;
          discountAmt = b.discountAmount;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 96),
          children: [
            const Text('Payment Method',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            _MethodTile(
                icon: Icons.credit_card,
                title: 'Credit/Debit Card',
                subtitle: 'Pay securely with your card',
                selected: method == 'card',
                onTap: () => setState(() => method = 'card')),
            const SizedBox(height: 10),
            _MethodTile(
                icon: Icons.payments_outlined,
                title: 'Cash Payment',
                subtitle: 'Pay with cash on arrival',
                selected: method == 'cash',
                onTap: () => setState(() => method = 'cash')),
            const SizedBox(height: 18),
            if (method == 'card') ...[
              EduStayTextField(
                  controller: card,
                  label: 'Card Number',
                  hint: '1234 5678 9012 3456',
                  keyboardType: TextInputType.number,
                  validator: (v) => RegExp(r'^\d{16}$')
                          .hasMatch((v ?? '').replaceAll(' ', ''))
                      ? null
                      : 'Enter a 16 digit card number'),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                    child: EduStayTextField(
                        controller: expiry,
                        label: 'Expiry Date',
                        hint: 'MM/YY',
                        validator: (v) => RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$')
                                .hasMatch(v ?? '')
                            ? null
                            : 'Use MM/YY')),
                const SizedBox(width: 12),
                Expanded(
                    child: EduStayTextField(
                        controller: cvv,
                        label: 'CVV',
                        hint: '123',
                        keyboardType: TextInputType.number,
                        validator: (v) => RegExp(r'^\d{3,4}$').hasMatch(v ?? '')
                            ? null
                            : 'Invalid CVV')),
              ]),
              const SizedBox(height: 14),
              EduStayTextField(
                  controller: holder,
                  label: 'Cardholder Name',
                  hint: 'Name on card',
                  validator: (v) => (v ?? '').trim().length >= 3
                      ? null
                      : 'Enter cardholder name'),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payment Summary',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  const SizedBox(height: 14),
                  if (baseTotal > 0)
                    _BreakdownRow(label: 'Monthly rent', value: baseTotal),
                  if (deposit > 0)
                    _BreakdownRow(label: 'Security deposit', value: deposit),
                  if (serviceFee > 0)
                    _BreakdownRow(label: 'Service fee', value: serviceFee),
                  // Always show discount if there is one, even 0% - but hide if literally 0
                  _BreakdownRow(
                      label: 'Owner discount (${discountPct.toStringAsFixed(0)}%)',
                      value: -discountAmt),
                  const Divider(height: 24),
                  _BreakdownRow(
                    label: 'Total Amount',
                    value: amount,
                    strong: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(18),
        child: EduStayPrimaryButton(
          label: bookingId == null
              ? 'Loading...'
              : 'Pay \$${amount.toStringAsFixed(2)}',
          color: EduStayColors.success,
          loading: loading,
          onPressed: () async {
            if (bookingId == null) return;
            if (method == 'card' && !formKey.currentState!.validate()) return;
            setState(() => loading = true);
            try {
              await context
                  .read<PaymentService>()
                  .pay(bookingId: bookingId!, method: method);
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, EduStayShell.route, (_) => false,
                    arguments: 3);
              }
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Payment failed. Please try again.')));
              }
            } finally {
              if (mounted) setState(() => loading = false);
            }
          },
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
    this.strong = false,
  });
  final String label;
  final double value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final prefix = value >= 0 ? '' : '-';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Expanded(
          child: Text(label,
              style: TextStyle(
                  fontWeight: strong ? FontWeight.w900 : FontWeight.w500,
                  fontSize: strong ? 14 : 13)),
        ),
        const SizedBox(width: 12),
        Text('$prefix\$${value.abs().toStringAsFixed(2)}',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: strong ? 19 : 13,
                color: strong
                    ? EduStayColors.darkGreen
                    : value < 0
                        ? EduStayColors.error
                        : EduStayColors.text)),
      ]),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.selected,
      required this.onTap});
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
        decoration: BoxDecoration(
            color: selected ? EduStayColors.softGreen : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color:
                    selected ? EduStayColors.darkGreen : EduStayColors.line)),
        child: Row(children: [
          CircleAvatar(
              backgroundColor:
                  selected ? EduStayColors.darkGreen : const Color(0xFFF3F4F6),
              child: Icon(icon,
                  color:
                      selected ? Colors.white : EduStayColors.secondaryText)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(subtitle,
                style: const TextStyle(
                    color: EduStayColors.secondaryText, fontSize: 12)),
          ]),
        ]),
      ),
    );
  }
}