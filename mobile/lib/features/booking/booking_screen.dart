import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/EduStay_design.dart';
import '../../models/property.dart';
import '../../providers/booking_provider.dart';
import '../../providers/property_provider.dart';
import '../../widgets/EduStay_components.dart';
import '../payment/payment_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});
  static const route = '/booking';

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  Property? property;
  DateTime? from;
  DateTime? to;
  int guests = 1;
  int? selectedPropertyId;
  bool routeInitialized = false;
  final notes = TextEditingController();

  Future<void> _pick(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now()
          .add(const Duration(days: 18250)),
      initialDate: isFrom
          ? (from ?? DateTime.now())
          : (to ?? DateTime.now().add(const Duration(days: 30))),
    );
    if (picked != null) setState(() => isFrom ? from = picked : to = picked);
  }

  Map<String, dynamic> _calculateFinancials() {
    final rent = _effectivePrice();
    final discPct = (property?.stayDuration ?? 0).toDouble();
    int months = 1;
    int numberOfDays = 30;
    if (from != null && to != null) {
      numberOfDays = to!.difference(from!).inDays;
      if (numberOfDays < 1) numberOfDays = 1;
      months = (numberOfDays / 30).ceil();
      if (months < 1) months = 1;
    }
    final totalRent = rent * months;
    final deposit = 100.0;
    final discountVal = (totalRent + deposit) * (discPct / 100.0);
    final total = totalRent + deposit - discountVal;
    return {
      'base_price': rent,
      'price_period': 'month',
      'number_of_days': numberOfDays,
      'base_total': totalRent,
      'discount_percent': discPct,
      'discount_amount': discountVal,
      'service_fee': 0,
      'security_deposit': deposit,
      'final_total': total,
    };
  }

  double _effectivePrice() {
    // Use price from the properties list if available (it loads faster)
    // Fall back to the selected property details
    final pid = selectedPropertyId;
    if (pid != null) {
      final props = context.read<PropertyProvider>().properties;
      final found = props.where((p) => p.id == pid).toList();
      if (found.isNotEmpty && found.first.price > 0) {
        return found.first.price;
      }
    }
    return property?.price ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    Property? property = arg is Property ? arg : null;

    if (!routeInitialized) {
      if (property != null) {
        selectedPropertyId = property.id;
      } else if (arg is int) {
        selectedPropertyId = arg;
      }
      routeInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PropertyProvider>().load();
        if (selectedPropertyId != null) {
          context.read<PropertyProvider>().open(selectedPropertyId!);
        }
      });
    }

    final properties = context.watch<PropertyProvider>().properties;
    final selectedFromList = _findProperty(properties, selectedPropertyId);
    property = selectedFromList ?? context.watch<PropertyProvider>().selected;

    final booking = context.watch<BookingProvider>();
    final monthlyPrice = property?.price;
    final preselected = ModalRoute.of(context)!.settings.arguments is int;
    final rent = _effectivePrice();
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 96),
        children: [
          if (!preselected) ...[
            DropdownButtonFormField<int>(
              value: selectedPropertyId,
              decoration: const InputDecoration(
                  labelText: 'Property', hintText: 'Select available property'),
              items: properties
                  .map((item) =>
                      DropdownMenuItem(value: item.id, child: Text(item.title)))
                  .toList(),
              onChanged: (value) => setState(() => selectedPropertyId = value),
            ),
            const SizedBox(height: 14),
          ],
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                      color: EduStayColors.line,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.apartment)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(property?.title ?? 'Property details loading',
                        maxLines: 2,
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(property?.location ?? 'Location unavailable',
                        style: const TextStyle(
                            color: EduStayColors.secondaryText, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text(
                        monthlyPrice == null
                            ? 'Price unavailable'
                            : '\$${monthlyPrice.toStringAsFixed(0)}/month',
                        style: const TextStyle(
                            color: EduStayColors.darkGreen,
                            fontWeight: FontWeight.w900)),
                  ])),
            ]),
          ),
          const SizedBox(height: 18),
          _DateTile(
              label: 'Move-in Date', value: from, onTap: () => _pick(true)),
          const SizedBox(height: 14),
          _DateTile(
              label: 'Move-out Date', value: to, onTap: () => _pick(false)),
          const SizedBox(height: 18),
          const Text('Number of Guests',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.group_outlined,
                  color: EduStayColors.secondaryText),
              const SizedBox(width: 10),
              const Text('Guests'),
              const Spacer(),
              IconButton(
                  onPressed: guests > 1 ? () => setState(() => guests--) : null,
                  icon: const Icon(Icons.remove_circle_outline)),
              Text('$guests',
                  style: const TextStyle(fontWeight: FontWeight.w900)),
              IconButton(
                  onPressed: () => setState(() => guests++),
                  icon: const Icon(Icons.add_circle_outline)),
            ]),
          ),
          const SizedBox(height: 18),
          EduStayTextField(
              controller: notes,
              label: 'Additional Notes (Optional)',
              hint: 'Any special requests or information...',
              maxLines: 4),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Price Summary',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                Builder(builder: (context) {
                  final discPct = (property?.stayDuration ?? 0).toDouble();
                  int months = 1;
                  if (from != null && to != null) {
                    final days = to!.difference(from!).inDays;
                    months = (days / 30).ceil();
                    if (months < 1) months = 1;
                  }
                  final totalRent = rent * months;
                  final deposit = 100.0;
                  final subtotal = totalRent + deposit;
                  final discountVal = subtotal * (discPct / 100.0);
                  final total = subtotal - discountVal;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PriceRow(
                          label: 'Monthly rent ($months mos)',
                          value: totalRent),
                      _PriceRow(
                          label: 'Security deposit (\$100)', value: deposit),
                      if (discPct > 0)
                        _PriceRow(
                            label: 'Owner Discount ($discPct%)',
                            value: -discountVal),
                      const Divider(),
                      _PriceRow(label: 'Total', value: total, strong: true),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(18),
        child: EduStayPrimaryButton(
          label: 'Confirm Booking',
          loading: booking.loading,
          onPressed: () async {
            if (from == null || to == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Choose move-in and move-out dates.')));
              return;
            }
            if (selectedPropertyId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Select a property.')));
              return;
            }
            final financials = _calculateFinancials();
            final created = await context
                .read<BookingProvider>()
                .create(selectedPropertyId!, from!, to!, guests,
                    financials: financials);
            if (context.mounted) {
              if (created != null) {
                Navigator.pushReplacementNamed(
                    context, PaymentScreen.route,
                    arguments: {
                      'bookingId': created.id,
                      'amount': financials['final_total'],
                      'baseTotal': financials['base_total'],
                      'deposit': financials['security_deposit'],
                      'serviceFee': financials['service_fee'],
                      'discountPct': financials['discount_percent'],
                      'discountAmt': financials['discount_amount'],
                    });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        'Booking failed. Try different dates or check your connection.')));
              }
            }
          },
        ),
      ),
    );
  }

  Property? _findProperty(List<Property> properties, int? id) {
    if (id == null) return null;
    for (final property in properties) {
      if (property.id == id) return property;
    }
    return null;
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile(
      {required this.label, required this.value, required this.onTap});
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: EduStayColors.line)),
          child: Row(children: [
            const Icon(Icons.calendar_month_outlined,
                size: 19, color: EduStayColors.secondaryText),
            const SizedBox(width: 12),
            Text(
                value == null
                    ? 'mm/dd/yyyy'
                    : value!.toString().substring(0, 10),
                style: TextStyle(
                    color: value == null
                        ? EduStayColors.secondaryText
                        : EduStayColors.text)),
            const Spacer(),
            const Icon(Icons.event, size: 18),
          ]),
        ),
      ),
    ]);
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow(
      {required this.label, required this.value, this.strong = false});
  final String label;
  final double value;
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
        Text('\$${value.toStringAsFixed(0)}',
            style: TextStyle(
                fontSize: strong ? 19 : 13,
                color: strong ? EduStayColors.darkGreen : EduStayColors.text,
                fontWeight: FontWeight.w900)),
      ]),
    );
  }
}