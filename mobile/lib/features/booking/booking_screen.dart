import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/studyhub_design.dart';
import '../../models/property.dart';
import '../../providers/booking_provider.dart';
import '../../providers/property_provider.dart';
import '../../widgets/studyhub_components.dart';
import '../payment/payment_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});
  static const route = '/booking';

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
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
      lastDate: DateTime.now().add(const Duration(days: 730)),
      initialDate: isFrom ? (from ?? DateTime.now()) : (to ?? DateTime.now().add(const Duration(days: 30))),
    );
    if (picked != null) setState(() => isFrom ? from = picked : to = picked);
  }

  @override
  Widget build(BuildContext context) {
    if (!routeInitialized) {
      final arg = ModalRoute.of(context)!.settings.arguments;
      if (arg is int) selectedPropertyId = arg;
      routeInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PropertyProvider>().load();
        if (selectedPropertyId != null) context.read<PropertyProvider>().open(selectedPropertyId!);
      });
    }
    final properties = context.watch<PropertyProvider>().properties;
    final selectedFromList = _findProperty(properties, selectedPropertyId);
    final property = selectedFromList ?? context.watch<PropertyProvider>().selected;
    final booking = context.watch<BookingProvider>();
    final monthlyPrice = property?.price;
    final preselected = ModalRoute.of(context)!.settings.arguments is int;
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 96),
        children: [
          if (!preselected) ...[
            DropdownButtonFormField<int>(
              value: selectedPropertyId,
              decoration: const InputDecoration(labelText: 'Property', hintText: 'Select available property'),
              items: properties.map((item) => DropdownMenuItem(value: item.id, child: Text(item.title))).toList(),
              onChanged: (value) => setState(() => selectedPropertyId = value),
            ),
            const SizedBox(height: 14),
          ],
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF7F8FA), borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Container(width: 78, height: 78, decoration: BoxDecoration(color: StudyHubColors.line, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.apartment)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(property?.title ?? 'Property details loading', maxLines: 2, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(property?.location ?? 'Location unavailable', style: const TextStyle(color: StudyHubColors.secondaryText, fontSize: 12)),
                const SizedBox(height: 8),
                Text(monthlyPrice == null ? 'Price unavailable' : '\$${monthlyPrice.toStringAsFixed(0)}/month', style: const TextStyle(color: StudyHubColors.darkGreen, fontWeight: FontWeight.w900)),
              ])),
            ]),
          ),
          const SizedBox(height: 18),
          _DateTile(label: 'Move-in Date', value: from, onTap: () => _pick(true)),
          const SizedBox(height: 14),
          _DateTile(label: 'Move-out Date', value: to, onTap: () => _pick(false)),
          const SizedBox(height: 18),
          const Text('Number of Guests', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: const Color(0xFFF7F8FA), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.group_outlined, color: StudyHubColors.secondaryText),
              const SizedBox(width: 10),
              const Text('Guests'),
              const Spacer(),
              IconButton(onPressed: guests > 1 ? () => setState(() => guests--) : null, icon: const Icon(Icons.remove_circle_outline)),
              Text('$guests', style: const TextStyle(fontWeight: FontWeight.w900)),
              IconButton(onPressed: () => setState(() => guests++), icon: const Icon(Icons.add_circle_outline)),
            ]),
          ),
          const SizedBox(height: 18),
          StudyHubTextField(controller: notes, label: 'Additional Notes (Optional)', hint: 'Any special requests or information...', maxLines: 4),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF7F8FA), borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Price Summary', style: TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              _PriceRow(label: 'Monthly rent', value: monthlyPrice ?? 0.0),
              _PriceRow(label: 'Security deposit', value: monthlyPrice ?? 0.0),
              const _PriceRow(label: 'Service fee', value: 50.0),
              const Divider(),
              _PriceRow(label: 'Total', value: (monthlyPrice ?? 0.0) * 2 + 50.0, strong: true),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(18),
        child: StudyHubPrimaryButton(
          label: 'Confirm Booking',
          loading: booking.loading,
          onPressed: () async {
            if (from == null || to == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choose move-in and move-out dates.')));
              return;
            }
            if (selectedPropertyId == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a property.')));
              return;
            }
            final created = await context.read<BookingProvider>().create(selectedPropertyId!, from!, to!, guests);
            if (context.mounted) Navigator.pushReplacementNamed(context, PaymentScreen.route, arguments: created.id);
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
  const _DateTile({required this.label, required this.value, required this.onTap});
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(14), border: Border.all(color: StudyHubColors.line)),
          child: Row(children: [
            const Icon(Icons.calendar_month_outlined, size: 19, color: StudyHubColors.secondaryText),
            const SizedBox(width: 12),
            Text(value == null ? 'mm/dd/yyyy' : value!.toString().substring(0, 10), style: TextStyle(color: value == null ? StudyHubColors.secondaryText : StudyHubColors.text)),
            const Spacer(),
            const Icon(Icons.event, size: 18),
          ]),
        ),
      ),
    ]);
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value, this.strong = false});
  final String label;
  final double value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Text(label, style: TextStyle(fontWeight: strong ? FontWeight.w900 : FontWeight.w500)),
        const Spacer(),
        Text('\$${value.toStringAsFixed(0)}', style: TextStyle(fontSize: strong ? 19 : 13, color: strong ? StudyHubColors.darkGreen : StudyHubColors.text, fontWeight: FontWeight.w900)),
      ]),
    );
  }
}
