import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/EduStay_design.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/EduStay_components.dart';
import '../payment/payment_history_screen.dart';
import 'booking_screen.dart';
import 'edit_booking_screen.dart';

class BookingsDashboardScreen extends StatefulWidget {
  const BookingsDashboardScreen({super.key, this.embedded = false});
  static const route = '/bookings-dashboard';

  final bool embedded;

  @override
  State<BookingsDashboardScreen> createState() =>
      _BookingsDashboardScreenState();
}

class _BookingsDashboardScreenState extends State<BookingsDashboardScreen> {
  String filter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<BookingProvider>().loadMine());
  }

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<BookingProvider>().bookings;
    final filtered = filter == 'All'
        ? bookings
        : bookings
            .where((item) => item.status.toLowerCase() == filter.toLowerCase())
            .toList();
    return Scaffold(
      appBar: widget.embedded
          ? null
          : AppBar(
              title: const Text('My Dashboard'),
              actions: [
                IconButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, BookingScreen.route),
                    icon: const Icon(Icons.add))
              ],
            ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            if (widget.embedded)
              const Padding(
                padding: EdgeInsets.only(bottom: 18),
                child: Text('My Dashboard',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              ),
            Row(
              children: [
                Expanded(
                    child: _MetricCard(
                        icon: Icons.calendar_month_outlined,
                        value: '${bookings.length}',
                        label: 'Total Bookings',
                        color: EduStayColors.darkGreen)),
                const SizedBox(width: 12),
                Expanded(
                    child: _MetricCard(
                        icon: Icons.check_circle_outline,
                        value:
                            '${bookings.where((b) => b.status == 'approved').length}',
                        label: 'Active Bookings',
                        color: EduStayColors.orange)),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  'All',
                  'Pending',
                  'Approved',
                  'Rejected',
                  'Cancelled',
                  'Completed'
                ].map((status) {
                  final selected = filter == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: selected,
                      label: Text(status),
                      onSelected: (_) => setState(() => filter = status),
                      selectedColor: EduStayColors.darkGreen,
                      labelStyle: TextStyle(
                          color: selected ? Colors.white : EduStayColors.text,
                          fontWeight: FontWeight.w800),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('My Bookings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            if (filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(
                    child: Text('No bookings yet.',
                        style: TextStyle(color: EduStayColors.secondaryText))),
              ),
            ...filtered.asMap().entries.map((entry) {
              final booking = entry.value;
              return FadeSlideIn(
                delay: Duration(milliseconds: entry.key * 40),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: EduStayShadows.soft),
                  child: Row(
                    children: [
                      Container(
                          width: 74,
                          height: 74,
                          decoration: BoxDecoration(
                              color: EduStayColors.line,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.apartment,
                              color: EduStayColors.darkGreen)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                booking.propertyTitle ??
                                    'Property #${booking.propertyId}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900)),
                            if ((booking.propertyLocation ?? '').isNotEmpty)
                              Text(booking.propertyLocation!,
                                  style: const TextStyle(
                                      color: EduStayColors.secondaryText,
                                      fontSize: 12)),
                            const SizedBox(height: 5),
                            Text(
                                '${booking.dateFrom.toString().substring(0, 10)} to ${booking.dateTo.toString().substring(0, 10)}',
                                style: const TextStyle(
                                    color: EduStayColors.secondaryText,
                                    fontSize: 12)),
                            const SizedBox(height: 7),
                            Row(children: [
                              Text(
                                  booking.propertyPrice == null
                                      ? 'Price unavailable'
                                      : '\$${booking.propertyPrice!.toStringAsFixed(0)}/mo',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: EduStayColors.darkGreen)),
                              const Spacer(),
                              _StatusPill(status: booking.status),
                            ]),
                            if (['pending', 'rejected', 'cancelled']
                                .contains(booking.status)) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  TextButton(
                                      onPressed: () => Navigator.pushNamed(
                                          context, EditBookingScreen.route,
                                          arguments: booking),
                                      child: const Text('Edit')),
                                  TextButton(
                                      onPressed: () => _confirm(
                                          context,
                                          'Cancel booking?',
                                          () => context
                                              .read<BookingProvider>()
                                              .cancelBooking(booking.id)),
                                      child: const Text('Cancel')),
                                  TextButton(
                                      onPressed: () => _confirm(
                                          context,
                                          'Delete booking?',
                                          () => context
                                              .read<BookingProvider>()
                                              .deleteBooking(booking.id)),
                                      child: const Text('Delete')),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 6),
            const Text('Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _ActionCard(
                        icon: Icons.add_box_outlined,
                        label: 'New Booking',
                        onTap: () =>
                            Navigator.pushNamed(context, BookingScreen.route))),
                const SizedBox(width: 12),
                Expanded(
                    child: _ActionCard(
                        icon: Icons.receipt_long_outlined,
                        label: 'Payments',
                        onTap: () => Navigator.pushNamed(
                            context, PaymentHistoryScreen.route))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context, String title,
      Future<void> Function() action) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: const Text('This action will update your booking.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes')),
        ],
      ),
    );
    if (ok == true) await action();
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.all(16),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: Colors.white, size: 28),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 24)),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ]),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'cancelled' => EduStayColors.error,
      'pending' => EduStayColors.orange,
      _ => EduStayColors.success,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(.12),
          borderRadius: BorderRadius.circular(12)),
      child: Text(status,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        height: 96,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: EduStayShadows.soft),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircleAvatar(
              backgroundColor: EduStayColors.softOrange,
              child: Icon(icon, color: EduStayColors.orange)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ]),
      ),
    );
  }
}
