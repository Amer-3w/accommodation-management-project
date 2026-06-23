import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/EduStay_design.dart';
import '../../repositories/admin_repository.dart';
import 'admin_components.dart';

class AdminListScreen extends StatefulWidget {
  const AdminListScreen({super.key, this.embeddedMode});
  static const route = '/admin-list';
  final String? embeddedMode;

  @override
  State<AdminListScreen> createState() => _AdminListScreenState();
}

class _AdminListScreenState extends State<AdminListScreen> {
  List<dynamic> rows = [];
  Map<String, dynamic> payload = {};
  String mode = 'dashboard';
  bool loading = true;
  String? error;
  String? loadedMode;
  String query = '';
  String filter = 'All';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg =
        widget.embeddedMode ?? ModalRoute.of(context)?.settings.arguments;
    if (arg is String) mode = arg;
    if (loadedMode != mode) {
      loadedMode = mode;
      query = '';
      filter = 'All';
      load();
    }
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final repo = context.read<AdminRepository>();
      final response = switch (mode) {
        'dashboard' => await repo.dashboard(),
        'analytics' => await repo.analytics(),
        'bookings' => await repo.bookings(),
        'properties' => await repo.properties(),
        'payments' => await repo.payments(),
        'support' => await repo.supportMessages(),
        'reviews' => await repo.reviews(),
        'notifications' => await repo.notifications(),
        'owners' => await repo.owners(),
        _ => await repo.users(),
      };
      final data = response['data'];
      setState(() {
        if (mode == 'dashboard' || mode == 'analytics') {
          payload = Map<String, dynamic>.from(data as Map);
          rows = [];
        } else {
          rows = data is Map && data['data'] is List
              ? data['data'] as List<dynamic>
              : data as List<dynamic>;
          payload = {};
        }
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _body();
    if (widget.embeddedMode != null) return body;
    return Scaffold(appBar: AppBar(title: Text(_title)), body: body);
  }

  String get _title => switch (mode) {
        'dashboard' => 'Dashboard',
        'analytics' => 'Reports / Analytics',
        'owners' => 'Owners',
        'properties' => 'Properties',
        'bookings' => 'Bookings',
        'payments' => 'Payments',
        'reviews' => 'Reviews',
        'support' => 'Support Messages',
        'notifications' => 'Notifications',
        _ => 'Users',
      };

  Widget _body() {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: EduStayColors.error)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
              onPressed: load,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry')),
        ]),
      );
    }
    if (mode == 'dashboard') return _dashboard();
    if (mode == 'analytics') return _analytics();
    return _tablePage();
  }

  Widget _dashboard() {
    final summary = _map(payload['summary']);
    return RefreshIndicator(
      onRefresh: load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 10) /
                  2; // Dynamically splits the exact available screen space in half
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                      width: cardWidth,
                      child: _stat('Total users', summary['total_users'],
                          Icons.people_outline)),
                  SizedBox(
                      width: cardWidth,
                      child: _stat('Owners', summary['total_owners'],
                          Icons.store_outlined,
                          orange: true)),
                  SizedBox(
                      width: cardWidth,
                      child: _stat('Properties', summary['total_properties'],
                          Icons.apartment_outlined)),
                  SizedBox(
                      width: cardWidth,
                      child: _stat(
                          'Active properties',
                          summary['active_properties'],
                          Icons.check_circle_outline,
                          orange: true)),
                  SizedBox(
                      width: cardWidth,
                      child: _stat(
                          'Pending properties',
                          summary['pending_properties'],
                          Icons.pending_actions)),
                  SizedBox(
                      width: cardWidth,
                      child: _stat('Bookings', summary['total_bookings'],
                          Icons.calendar_month_outlined,
                          orange: true)),
                  SizedBox(
                      width: cardWidth,
                      child: _stat('Pending bookings',
                          summary['pending_bookings'], Icons.hourglass_empty)),
                  SizedBox(
                      width: cardWidth,
                      child: _stat('Approved bookings',
                          summary['approved_bookings'], Icons.verified_outlined,
                          orange: true)),
                  SizedBox(
                      width: cardWidth,
                      child: _stat(
                          'Cancelled bookings',
                          summary['cancelled_bookings'],
                          Icons.cancel_outlined)),
                  SizedBox(
                      width: cardWidth,
                      child: _stat('Payments', summary['total_payments'],
                          Icons.payments_outlined,
                          orange: true)),
                  SizedBox(
                      width: cardWidth,
                      child: _stat('Revenue', '\$${summary['revenue'] ?? 0}',
                          Icons.trending_up)),
                  SizedBox(
                      width: cardWidth,
                      child: _stat(
                          'Reviews', summary['reviews'], Icons.star_border,
                          orange: true)),
                  SizedBox(
                      width: cardWidth,
                      child: _stat(
                          'Support messages',
                          summary['support_messages'],
                          Icons.support_agent_outlined)),
                  SizedBox(
                      width: cardWidth,
                      child: _stat(
                          'Unread notifications',
                          summary['unread_notifications'],
                          Icons.notifications_outlined,
                          orange: true)),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          LayoutBuilder(builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    width: double.infinity,
                    child: AdminChartCard(
                        title: 'Bookings by status',
                        values: _map(payload['booking_statuses']))),
                const SizedBox(height: 14),
                SizedBox(
                    width: double.infinity,
                    child: AdminChartCard(
                        title: 'Payments summary',
                        values: _map(payload['payment_statuses']))),
                const SizedBox(height: 14),
                SizedBox(
                    width: double.infinity,
                    child: AdminChartCard(
                        title: 'Users by role',
                        values: _map(payload['users_by_role']))),
                const SizedBox(height: 14),
                SizedBox(
                    width: double.infinity,
                    child: AdminChartCard(
                        title: 'Properties by city',
                        values: _map(payload['properties_by_city']))),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _analytics() {
    final summary = _map(payload['summary']);
    final topCities = {
      for (final item in _list(payload['top_cities']))
        _text(item['city']): item['total']
    };
    final topProperties = {
      for (final item in _list(payload['top_properties']))
        _text(item['title']): item['bookings_count']
    };
    final topOwners = {
      for (final item in _list(payload['top_owners']))
        _text(item['name']): item['properties_count']
    };
    final paymentSummary = {
      for (final item in _list(payload['payments_summary']))
        _text(item['status']): item['amount'] ?? item['total']
    };

    return RefreshIndicator(
      onRefresh: load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                      width: cardWidth,
                      child: _stat('Total revenue',
                          '\$${summary['revenue'] ?? 0}', Icons.trending_up)),
                  SizedBox(
                      width: cardWidth,
                      child: cardWidth > 0
                          ? _stat('Total bookings', summary['total_bookings'],
                              Icons.calendar_month_outlined,
                              orange: true)
                          : const SizedBox()),
                  SizedBox(
                      width: cardWidth,
                      child: _stat('Total users', summary['total_users'],
                          Icons.people_outline)),
                  SizedBox(
                      width: cardWidth,
                      child: _stat('Total payments', summary['total_payments'],
                          Icons.payments_outlined,
                          orange: true)),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          LayoutBuilder(builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    width: double.infinity,
                    child: AdminChartCard(
                        title: 'Bookings by month',
                        values: _map(payload['bookings_by_month']))),
                const SizedBox(height: 14),
                SizedBox(
                    width: double.infinity,
                    child: AdminChartCard(
                        title: 'Users growth',
                        values: _map(payload['users_growth']))),
                const SizedBox(height: 14),
                SizedBox(
                    width: double.infinity,
                    child: AdminChartCard(
                        title: 'Top properties', values: topProperties)),
                const SizedBox(height: 14),
                SizedBox(
                    width: double.infinity,
                    child:
                        AdminChartCard(title: 'Top owners', values: topOwners)),
                const SizedBox(height: 14),
                SizedBox(
                    width: double.infinity,
                    child:
                        AdminChartCard(title: 'Top cities', values: topCities)),
                const SizedBox(height: 14),
                SizedBox(
                    width: double.infinity,
                    child: AdminChartCard(
                        title: 'Payments summary', values: paymentSummary)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _tablePage() {
    final visible = _visibleRows();
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 32, 22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _title,
                style: TextStyle(
                  fontSize: mode == 'support'
                      ? 17
                      : 22, // Keeps your custom Support Messages fix intact
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
              visualDensity: VisualDensity.compact,
              tooltip: 'Refresh',
              onPressed: load,
              icon: const Icon(Icons.refresh, size: 20)),
          const SizedBox(width: 8),
          IconButton.filled(
              visualDensity: VisualDensity.compact,
              tooltip: 'Add',
              onPressed: _add,
              icon: const Icon(Icons.add, size: 20)),
        ]),
        const SizedBox(height: 14),
        AdminFilterBar(
          query: query,
          onQuery: (value) => setState(() => query = value),
          filters: _filters,
          selectedFilter: filter,
          onFilter: (value) => setState(() => filter = value),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: visible.isEmpty
              ? Center(
                  child: Text('No ${_title.toLowerCase()} found.',
                      style:
                          const TextStyle(color: EduStayColors.secondaryText)))
              : AdminTable(
                  columns: _columns,
                  rows: visible,
                  cellBuilder: _cells,
                  actionBuilder: _actions),
        ),
      ]),
    );
  }

  AdminStatCard _stat(String label, dynamic value, IconData icon,
      {bool orange = false}) {
    return AdminStatCard(
        label: label, value: _text(value), icon: icon, orange: orange);
  }

  List<dynamic> _visibleRows() {
    return rows.where((row) {
      final map = Map<String, dynamic>.from(row as Map);
      final haystack = map.toString().toLowerCase();
      final matchesQuery =
          query.trim().isEmpty || haystack.contains(query.trim().toLowerCase());
      final matchesFilter = filter == 'All' || _rowFilterValue(map) == filter;
      return matchesQuery && matchesFilter;
    }).toList();
  }

  String _rowFilterValue(Map<String, dynamic> row) {
    if (mode == 'users' || mode == 'owners') return _text(row['role']);
    if (mode == 'properties') return _text(row['status']);
    if (mode == 'bookings') return _text(row['status']);
    if (mode == 'payments') return _text(row['status']);
    if (mode == 'reviews') return _text(row['rating']);
    if (mode == 'support') return _text(row['status']);
    if (mode == 'notifications')
      return row['read_at'] == null ? 'Unread' : 'Read';
    return 'All';
  }

  List<String> get _filters {
    final values = rows
        .map((row) => _rowFilterValue(Map<String, dynamic>.from(row as Map)))
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...values];
  }

  List<String> get _columns => switch (mode) {
        'owners' => [
            'ID',
            'Owner',
            'Email',
            'Phone',
            'Properties',
            'Bookings',
            'Revenue',
            'Rating'
          ],
        'users' => [
            'ID',
            'Name',
            'Email',
            'Phone',
            'Role',
            'City',
            'University',
            'Created'
          ],
        'properties' => [
            'ID',
            'Title',
            'Owner',
            'City',
            'University',
            'Type',
            'Price',
            'Status',
            'Rating',
            'Bookings'
          ],
        'bookings' => [
            'ID',
            'Tenant',
            'Property',
            'Owner',
            'Dates',
            'Guests',
            'Final Price',
            'Payment',
            'Status',
            'Created'
          ],
        'payments' => [
            'ID',
            'Tenant',
            'Property',
            'Owner',
            'Amount',
            'Method',
            'Status',
            'Date',
            'Booking'
          ],
        'reviews' => [
            'ID',
            'Tenant',
            'Property',
            'Owner',
            'Rating',
            'Comment',
            'Status',
            'Date'
          ],
        'support' => [
            'ID',
            'Sender',
            'Email / Phone',
            'Subject',
            'Message',
            'Status',
            'Date'
          ],
        'notifications' => ['Title', 'Message', 'Type', 'Read', 'Date'],
        _ => ['ID', 'Name', 'Email', 'Phone', 'Role'],
      };

  List<String> _cells(dynamic row) {
    final map = Map<String, dynamic>.from(row as Map);
    final property = _map(map['property']);
    final owner = _map(property['owner'] ?? map['owner']);
    final user = _map(map['user']);
    final booking = _map(map['booking']);
    final bookingProperty = _map(booking['property']);
    final notification = _notificationData(map);

    return switch (mode) {
      'owners' => [
          _text(map['id']),
          _text(map['name']),
          _text(map['email']),
          _text(map['phone']),
          _text(map['properties_count']),
          _text(map['bookings_count']),
          '\$${_text(map['revenue'])}',
          _text(map['rating'])
        ],
      'users' => [
          _text(map['id']),
          _text(map['name']),
          _text(map['email']),
          _text(map['phone']),
          _text(map['role']),
          _text(map['city']),
          _text(map['university']),
          _date(map['created_at'])
        ],
      'properties' => [
          _text(map['id']),
          _text(map['title']),
          _text(owner['name']),
          _text(map['city']),
          _text(map['university']),
          _text(map['property_type']),
          '\$${_text(map['price'])}',
          _text(map['status']),
          _avgRating(map),
          _text(map['bookings_count'] ?? '')
        ],
      'bookings' => [
          _text(map['id']),
          _text(user['name']),
          _text(property['title']),
          _text(owner['name']),
          '${_date(map['date_from'])} - ${_date(map['date_to'])}',
          _text(map['guests']),
          '\$${_text(map['final_total'])}',
          _text(_map(map['payment'])['status']),
          _text(map['status']),
          _date(map['created_at'])
        ],
      'payments' => [
          _text(map['id']),
          _text(_map(booking['user'])['name']),
          _text(bookingProperty['title']),
          _text(_map(bookingProperty['owner'])['name']),
          '\$${_text(map['amount'])}',
          _text(map['method']),
          _text(map['status']),
          _date(map['created_at']),
          '#${_text(map['booking_id'])}'
        ],
      'reviews' => [
          _text(map['id']),
          _text(user['name']),
          _text(property['title']),
          _text(owner['name']),
          _text(map['rating']),
          _text(map['comment']),
          map['moderated_at'] == null ? 'Visible' : 'Moderated',
          _date(map['created_at'])
        ],
      'support' => [
          _text(map['id']),
          _text(map['name']),
          '${_text(map['email'])} ${_text(map['phone'])}',
          _text(map['subject']),
          _text(map['message']),
          _text(map['status']),
          _date(map['created_at'])
        ],
      'notifications' => [
          _text(notification['title']),
          _text(notification['body']),
          _text(notification['category']),
          map['read_at'] == null ? 'Unread' : 'Read',
          _date(map['created_at'])
        ],
      _ => [
          _text(map['id']),
          _text(map['name']),
          _text(map['email']),
          _text(map['phone']),
          _text(map['role'])
        ],
    };
  }

  Widget _actions(dynamic row) {
    final map = Map<String, dynamic>.from(row as Map);
    return AdminActionButtons(
      onView: () => _view(map),
      onEdit: () => _edit(map),
      onDelete: () => _delete(map),
      extra: _statusButtons(map),
    );
  }

  List<Widget> _statusButtons(Map<String, dynamic> row) {
    if (mode == 'bookings') {
      return [
        PopupMenuButton<String>(
          tooltip: 'Booking status',
          icon: const Icon(Icons.rule_folder_outlined,
              color: EduStayColors.darkGreen),
          onSelected: (status) => _quickUpdate(row, {'status': status}),
          itemBuilder: (_) => ['approved', 'rejected', 'cancelled', 'completed']
              .map(
                  (status) => PopupMenuItem(value: status, child: Text(status)))
              .toList(),
        ),
      ];
    }
    if (mode == 'payments') {
      return [
        PopupMenuButton<String>(
          tooltip: 'Payment status',
          icon: const Icon(Icons.price_check_outlined,
              color: EduStayColors.darkGreen),
          onSelected: (status) => _quickUpdate(row, {'status': status}),
          itemBuilder: (_) => ['paid', 'failed', 'refunded', 'pending']
              .map(
                  (status) => PopupMenuItem(value: status, child: Text(status)))
              .toList(),
        ),
      ];
    }
    if (mode == 'support') {
      return [
        PopupMenuButton<String>(
          tooltip: 'Support status',
          icon: const Icon(Icons.task_alt_outlined,
              color: EduStayColors.darkGreen),
          onSelected: (status) => _quickUpdate(row, {'status': status}),
          itemBuilder: (_) => ['open', 'pending', 'resolved', 'closed']
              .map(
                  (status) => PopupMenuItem(value: status, child: Text(status)))
              .toList(),
        ),
      ];
    }
    if (mode == 'notifications') {
      return [
        IconButton(
            tooltip: 'Mark read',
            onPressed: () => _quickUpdate(row, {'read': true}),
            icon: const Icon(Icons.mark_email_read_outlined,
                color: EduStayColors.darkGreen))
      ];
    }
    return const [];
  }

  Future<void> _add() async {
    if (mode == 'users' || mode == 'owners') {
      await Navigator.pushNamed(context, AdminUserFormScreen.route,
          arguments: mode == 'owners' ? {'role': 'owner'} : null);
      load();
      return;
    }
    await _openEditor(null);
  }

  Future<void> _edit(Map<String, dynamic> row) async {
    if (mode == 'users' || mode == 'owners') {
      await Navigator.pushNamed(context, AdminUserFormScreen.route,
          arguments: row);
      load();
      return;
    }
    await _openEditor(row);
  }

  Future<void> _quickUpdate(
      Map<String, dynamic> row, Map<String, dynamic> body) async {
    await _runAction(() async => _save(row, body), 'Updated successfully.');
  }

  Future<void> _openEditor(Map<String, dynamic>? row) async {
    final fields = _editableFields(row);
    if (fields.isEmpty) return;
    final controllers = {
      for (final field in fields)
        field.key: TextEditingController(text: field.initial)
    };
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(row == null ? 'Add $_title' : 'Edit $_title'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
                children: fields.map((field) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                    controller: controllers[field.key],
                    decoration: InputDecoration(labelText: field.label)),
              );
            }).toList()),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (saved != true) return;
    final body = {
      for (final field in fields)
        field.key: _typedValue(field.key, controllers[field.key]!.text)
    };
    await _runAction(() async => _save(row, body),
        row == null ? 'Created successfully.' : 'Updated successfully.');
  }

  Future<void> _save(
      Map<String, dynamic>? row, Map<String, dynamic> body) async {
    final repo = context.read<AdminRepository>();
    final id = row?['id'];
    switch (mode) {
      case 'properties':
        id == null
            ? await repo.createProperty(body)
            : await repo.updateProperty(id, body);
        break;
      case 'bookings':
        id == null
            ? await repo.createBooking(body)
            : await repo.updateBooking(id, body);
        break;
      case 'payments':
        id == null
            ? await repo.createPayment(body)
            : await repo.updatePayment(id, body);
        break;
      case 'reviews':
        id == null
            ? await repo.createReview(body)
            : await repo.updateReview(id, body);
        break;
      case 'support':
        id == null
            ? await repo.createSupportMessage(body)
            : await repo.updateSupportMessage(id, body);
        break;
      case 'notifications':
        id == null
            ? await repo.createNotification(body)
            : await repo.updateNotification(
                id.toString(), {'read': body['read'] == true});
        break;
    }
  }

  Future<void> _delete(Map<String, dynamic> row) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm delete'),
        content: Text(
            'Delete this ${_title.toLowerCase().replaceAll(' messages', ' message')}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    await _runAction(() async {
      final repo = context.read<AdminRepository>();
      final id = row['id'];
      switch (mode) {
        case 'users':
        case 'owners':
          await repo.deleteUser(id);
          break;
        case 'properties':
          await repo.deleteAdminProperty(id);
          break;
        case 'bookings':
          await repo.deleteBooking(id);
          break;
        case 'payments':
          await repo.deletePayment(id);
          break;
        case 'reviews':
          await repo.deleteAdminReview(id);
          break;
        case 'support':
          await repo.deleteSupportMessage(id);
          break;
        case 'notifications':
          await repo.deleteNotification(id.toString());
          break;
      }
    }, 'Deleted successfully.');
  }

  Future<void> _runAction(
      Future<void> Function() action, String success) async {
    try {
      await action();
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(success)));
      await load();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString()), backgroundColor: EduStayColors.error));
    }
  }

  void _view(Map<String, dynamic> row) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$_title Details',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: row.entries.where((entry) {
                // Filters out unneeded system timestamp clutter and photo arrays
                return ![
                  'created_at',
                  'updated_at',
                  'profile_photo_path',
                  'profile_photo_url'
                ].contains(entry.key);
              }).map((entry) {
                // Cleans up the keys (e.g. from 'date_of_birth' to 'DATE OF BIRTH')
                final keyName = entry.key.replaceAll('_', ' ').toUpperCase();
                final valueText =
                    entry.value == null || entry.value.toString() == 'null'
                        ? 'Not Provided'
                        : entry.value.toString();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          color: Colors.black, fontSize: 13, height: 1.3),
                      children: [
                        TextSpan(
                            text: '• $keyName: ',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: valueText),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close',
                style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  List<_AdminField> _editableFields(Map<String, dynamic>? row) {
    String value(String key) => _text(row?[key]);
    return switch (mode) {
      'properties' => [
          _AdminField('title', 'Title', value('title')),
          _AdminField('owner_id', 'Owner ID', value('owner_id')),
          _AdminField('price', 'Price', value('price')),
          _AdminField('location', 'Location', value('location')),
          _AdminField('description', 'Description', value('description')),
          _AdminField('city', 'City', value('city')),
          _AdminField('university', 'University', value('university')),
          _AdminField('property_type', 'Type', value('property_type')),
          _AdminField('status', 'Status', value('status')),
        ],
      'bookings' => [
          _AdminField('user_id', 'Tenant ID', value('user_id')),
          _AdminField('property_id', 'Property ID', value('property_id')),
          _AdminField('date_from', 'Date From', value('date_from')),
          _AdminField('date_to', 'Date To', value('date_to')),
          _AdminField('guests', 'Guests', value('guests')),
          _AdminField('status', 'Status', value('status')),
        ],
      'payments' => [
          _AdminField('booking_id', 'Booking ID', value('booking_id')),
          _AdminField('amount', 'Amount', value('amount')),
          _AdminField('method', 'Method', value('method')),
          _AdminField('status', 'Status', value('status')),
          _AdminField('reference', 'Reference', value('reference')),
        ],
      'reviews' => [
          _AdminField('user_id', 'Tenant ID', value('user_id')),
          _AdminField('property_id', 'Property ID', value('property_id')),
          _AdminField('rating', 'Rating', value('rating')),
          _AdminField('comment', 'Comment', value('comment')),
          _AdminField('owner_reply', 'Owner Reply', value('owner_reply')),
        ],
      'support' => [
          if (row == null) _AdminField('name', 'Name', ''),
          if (row == null) _AdminField('email', 'Email', ''),
          if (row == null) _AdminField('phone', 'Phone', ''),
          _AdminField('subject', 'Subject', value('subject')),
          _AdminField('message', 'Message', value('message')),
          _AdminField('status', 'Status', value('status')),
        ],
      'notifications' => row == null
          ? [
              _AdminField('user_id', 'User ID', ''),
              _AdminField('title', 'Title', ''),
              _AdminField('body', 'Body', ''),
              _AdminField('category', 'Category', 'admin')
            ]
          : [
              _AdminField('read', 'Read true/false',
                  row['read_at'] == null ? 'false' : 'true')
            ],
      _ => [],
    };
  }

  Object _typedValue(String key, String value) {
    if (['owner_id', 'user_id', 'property_id', 'booking_id', 'guests', 'rating']
        .contains(key)) return int.tryParse(value) ?? 0;
    if (['price', 'amount'].contains(key)) return double.tryParse(value) ?? 0.0;
    if (key == 'read') return value.toLowerCase() == 'true';
    return value;
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value == null || value is! Map) return <String, dynamic>{};
    return Map<String, dynamic>.from(value);
  }

  List<dynamic> _list(dynamic value) => value is List ? value : const [];

  String _text(dynamic value) {
    if (value == null) return '';
    final str = value.toString().trim();
    return str == 'null' ? '' : str;
  }

  String _date(dynamic value) {
    final t = _text(value);
    if (t.isEmpty) return '';
    return t.split('T').first;
  }

  Map<String, dynamic> _notificationData(Map<String, dynamic> row) =>
      _map(row['data']);
  String _avgRating(Map<String, dynamic> row) {
    final reviews = _list(row['reviews']);
    if (reviews.isEmpty) return '';
    final total = reviews.fold<double>(
        0,
        (sum, review) =>
            sum + (double.tryParse(_text(_map(review)['rating'])) ?? 0));
    return (total / reviews.length).toStringAsFixed(1);
  }
}

class _AdminField {
  const _AdminField(this.key, this.label, this.initial);
  final String key;
  final String label;
  final String initial;
}

class AdminUserFormScreen extends StatefulWidget {
  const AdminUserFormScreen({super.key});
  static const route = '/admin-user-form';

  @override
  State<AdminUserFormScreen> createState() => _AdminUserFormScreenState();
}

class _AdminUserFormScreenState extends State<AdminUserFormScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  String role = 'user';
  Map<String, dynamic>? editing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Map<String, dynamic> && editing == null) {
      editing = arg['id'] == null ? null : arg;
      name.text = arg['name'] ?? '';
      email.text = arg['email'] ?? '';
      phone.text = arg['phone'] ?? '';
      role = arg['role'] ?? 'user';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(editing == null ? 'Create User' : 'Edit User')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 12),
          TextField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 12),
          TextField(
              controller: phone,
              decoration: const InputDecoration(labelText: 'Phone')),
          const SizedBox(height: 12),
          TextField(
              controller: password,
              decoration: const InputDecoration(labelText: 'Password')),
          const SizedBox(height: 12),
          DropdownButtonFormField(
              value: role,
              items: ['admin', 'owner', 'user']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => role = v!),
              decoration: const InputDecoration(labelText: 'Role')),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () async {
              try {
                final body = {
                  'name': name.text,
                  'email': email.text,
                  'phone': phone.text,
                  'role': role,
                  if (password.text.isNotEmpty) 'password': password.text
                };
                final repo = context.read<AdminRepository>();
                if (editing == null) {
                  await repo.createUser(body);
                } else {
                  await repo.updateUser(editing!['id'], body);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('User saved successfully.')));
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted)
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: EduStayColors.error));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
