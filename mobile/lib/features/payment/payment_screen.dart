import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/EduStay_design.dart';
import '../../models/booking.dart';
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
  Booking? booking;
  int? bookingId;
  bool loadError = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (bookingId != null) return;
    final arg = ModalRoute.of(context)!.settings.arguments;
    if (arg is int) {
      bookingId = arg;
      context.read<BookingProvider>().details(arg).then((value) {
        if (mounted) setState(() {
          booking = value;
          loadError = false;
        });
      }).catchError((error) {
        if (mounted) setState(() => loadError = true);
        debugPrint('Payment load error: $error');
      });
    }
  }

  /// Calculate total the same way as the booking screen to guarantee consistency
  double _calculateTotal() {
    if (booking == null) return 0.0;
    // Prefer backend's finalTotal if it's non-zero
    if (booking!.finalTotal > 0) return booking!.finalTotal;
    // Fall back to local calculation matching booking screen
    final rent = booking!.basePrice;
    final months = (booking!.numberOfDays / 30).ceil().clamp(1, 999);
    final totalRent = rent * months;
    final deposit = booking!.securityDeposit > 0 ? booking!.securityDeposit : rent;
    final fee = booking!.serviceFee > 0 ? booking!.serviceFee : 50.0;
    final subtotal = totalRent + deposit + fee;
    final discPct = booking!.discountPercent;
    final discVal = subtotal * (discPct / 100.0);
    return subtotal - discVal;
  }

  @override
  Widget build(BuildContext context) {
    final double finalAmount = _calculateTotal();

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 96),
          children: [
            if (loadError)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: EduStayColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Could not load booking details. Please try again.',
                    style: TextStyle(color: EduStayColors.error)),
              ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount',
                    style: TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 16)),
                Text('\$${finalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: EduStayColors.darkGreen)),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(18),
        child: EduStayPrimaryButton(
          label: booking == null
              ? 'Loading...'
              : 'Pay \$${finalAmount.toStringAsFixed(2)}',
          color: EduStayColors.success,
          loading: loading,
          onPressed: () async {
            if (booking == null) return;
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
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment failed. Please try again.')));
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