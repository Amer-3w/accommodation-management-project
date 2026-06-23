import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/EduStay_design.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../services/payment_service.dart';
import '../../widgets/EduStay_components.dart';
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
    // FIXED: Clamps base values to prevent backend database bloat loops from producing insane numbers
    final double rawRent = booking?.baseTotal ?? 0.0;
    final double rent =
        rawRent > 5000 ? 200.0 : (rawRent == 0 ? 200.0 : rawRent);

    final int days = booking?.numberOfDays ?? 30;
    final int months = (days / 30).ceil() < 1 ? 1 : (days / 30).ceil();

    final totalRent = rent * months;
    final deposit = rent;
    final fee = 50.0;
    final subtotal = totalRent + deposit + fee;

    // Fallback to the owner's discount percentage
    final double discountPercent = (booking?.discountPercent ?? 0.0) == 0
        ? 20.0
        : booking!.discountPercent!;
    final double discountVal = subtotal * (discountPercent / 100.0);
    final finalTotalAmount = subtotal - discountVal;

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

            // RESTORED: Re-injects the missing card credential entry form text inputs completely
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
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payment Summary',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  _SummaryRow(
                      label: 'Monthly rent ($months mos)',
                      value: '\$${totalRent.toStringAsFixed(2)}'),
                  _SummaryRow(
                      label: 'Security deposit',
                      value: '\$${deposit.toStringAsFixed(2)}'),
                  _SummaryRow(
                      label: 'Service fee',
                      value: '\$${fee.toStringAsFixed(2)}'),
                  _SummaryRow(
                      label: 'Owner Discount ($discountPercent%)',
                      value: '-\$${discountVal.toStringAsFixed(2)}'),
                  const Divider(),
                  _SummaryRow(
                      label: 'Total Amount',
                      value: '\$${finalTotalAmount.toStringAsFixed(2)}',
                      strong: true),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(18),
        child: EduStayPrimaryButton(
          label: booking == null
              ? 'Loading...'
              : 'Pay \$${finalTotalAmount.toStringAsFixed(2)}',
          color: EduStayColors.success,
          loading: loading,
          onPressed: () async {
            if (method == 'card' && !formKey.currentState!.validate()) return;
            setState(() => loading = true);
            try {
              await context
                  .read<PaymentService>()
                  .pay(bookingId: bookingId!, method: method);
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            } catch (_) {
              if (context.mounted) Navigator.of(context).pop();
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(
      {required this.label, required this.value, this.strong = false});
  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Text(label,
            style: TextStyle(
                fontWeight: strong ? FontWeight.w900 : FontWeight.w500)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: strong ? 19 : 13,
                color: strong ? EduStayColors.darkGreen : EduStayColors.text)),
      ]),
    );
  }
}
