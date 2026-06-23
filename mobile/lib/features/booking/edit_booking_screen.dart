import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/EduStay_design.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/EduStay_components.dart';

class EditBookingScreen extends StatefulWidget {
  const EditBookingScreen({super.key});
  static const route = '/booking-edit';

  @override
  State<EditBookingScreen> createState() => _EditBookingScreenState();
}

class _EditBookingScreenState extends State<EditBookingScreen> {
  late Booking booking;
  late DateTime from;
  late DateTime to;
  late int guests;
  late TextEditingController notes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    booking = ModalRoute.of(context)!.settings.arguments as Booking;
    from = booking.dateFrom;
    to = booking.dateTo;
    guests = booking.guests;
    notes = TextEditingController(text: booking.notes);
  }

  Future<void> pick(bool isFrom) async {
    final picked = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 730)),
        initialDate: isFrom ? from : to);
    if (picked != null) setState(() => isFrom ? from = picked : to = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Booking')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              title: const Text('Move in'),
              subtitle: Text(from.toString().substring(0, 10)),
              trailing: const Icon(Icons.calendar_month),
              onTap: () => pick(true)),
          const SizedBox(height: 12),
          ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              title: const Text('Move out'),
              subtitle: Text(to.toString().substring(0, 10)),
              trailing: const Icon(Icons.calendar_month),
              onTap: () => pick(false)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Text('Guests',
                  style: TextStyle(fontWeight: FontWeight.w900)),
              const Spacer(),
              IconButton(
                  onPressed: guests > 1 ? () => setState(() => guests--) : null,
                  icon: const Icon(Icons.remove_circle_outline)),
              Text('$guests'),
              IconButton(
                  onPressed: () => setState(() => guests++),
                  icon: const Icon(Icons.add_circle_outline)),
            ]),
          ),
          const SizedBox(height: 16),
          EduStayTextField(controller: notes, label: 'Notes', maxLines: 4),
          const SizedBox(height: 24),
          EduStayPrimaryButton(
            label: 'Save Booking',
            onPressed: () async {
              await context
                  .read<BookingProvider>()
                  .updateBooking(booking.id, from, to, guests, notes.text);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
