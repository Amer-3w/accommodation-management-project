import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/EduStay_design.dart';
import '../../widgets/EduStay_components.dart';

class OwnerBookingsScreen extends StatefulWidget {
  const OwnerBookingsScreen({super.key});
  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> {
  bool loading = true;
  List<dynamic> bookings = [];
  String filter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final response = await context.read<ApiClient>().get('/owner/bookings');
    if (mounted) {
      setState(() {
        bookings = (response['data'] as List<dynamic>?) ?? [];
        loading = false;
      });
    }
  }

  Future<void> _updateStatus(int bookingId, String status) async {
    await context
        .read<ApiClient>()
        .put('/owner/bookings/$bookingId/status', {'status': status});
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filter == 'All'
        ? bookings
        : bookings.where((b) {
            final s = (b as Map<String, dynamic>)['status']?.toString() ?? '';
            return s.toLowerCase() == filter.toLowerCase();
          }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Owner Bookings')),
      body: Column(
        children: [
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              children: ['All', 'Pending', 'Approved', 'Rejected', 'Cancelled', 'Completed']
                  .map((status) {
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
          const SizedBox(height: 8),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(
                        child: Text('No bookings yet.',
                            style:
                                TextStyle(color: EduStayColors.secondaryText)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final booking =
                                filtered[i] as Map<String, dynamic>;
                            final user =
                                booking['user'] as Map<String, dynamic>?;
                            final property =
                                booking['property'] as Map<String, dynamic>?;
                            final status =
                                booking['status']?.toString() ?? 'pending';
                            final color = switch (status) {
                              'cancelled' || 'rejected' => EduStayColors.error,
                              'pending' => EduStayColors.orange,
                              _ => EduStayColors.success,
                            };
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Expanded(
                                        child: Text(
                                            property?['title']?.toString() ??
                                                'Property',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w900)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                            color: color.withOpacity(.12),
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        child: Text(status,
                                            style: TextStyle(
                                                color: color,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800)),
                                      ),
                                    ]),
                                    const SizedBox(height: 6),
                                    Text(
                                        'User: ${user?['name'] ?? user?['email'] ?? 'Unknown'}',
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color:
                                                EduStayColors.secondaryText)),
                                    Text(
                                        '${booking['date_from']?.toString()?.substring(0, 10) ?? ''} to ${booking['date_to']?.toString()?.substring(0, 10) ?? ''}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color:
                                                EduStayColors.secondaryText)),
                                    if (status == 'pending') ...[
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 36,
                                              child: ElevatedButton(
                                                style:
                                                    ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      EduStayColors.success,
                                                  foregroundColor: Colors.white,
                                                  shape:
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                ),
                                                onPressed: () =>
                                                    _updateStatus(
                                                        booking['id'], 'approved'),
                                                child: const Text('Accept',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w800)),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: SizedBox(
                                              height: 36,
                                              child: ElevatedButton(
                                                style:
                                                    ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      EduStayColors.error,
                                                  foregroundColor: Colors.white,
                                                  shape:
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                ),
                                                onPressed: () =>
                                                    _updateStatus(
                                                        booking['id'], 'rejected'),
                                                child: const Text('Reject',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w800)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (status == 'approved' ||
                                        status == 'paid' ||
                                        status == 'confirmed')
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: SizedBox(
                                          height: 32,
                                          child: TextButton(
                                            onPressed: () => _updateStatus(
                                                booking['id'], 'completed'),
                                            child: const Text('Mark Completed',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}