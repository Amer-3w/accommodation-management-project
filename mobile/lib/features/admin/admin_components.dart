import 'package:flutter/material.dart';

import '../../core/theme/studyhub_design.dart';

class AdminSidebarItem {
  const AdminSidebarItem(this.key, this.icon, this.label);
  final String key;
  final IconData icon;
  final String label;
}

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    required this.items,
    required this.selected,
    required this.collapsed,
    required this.onSelect,
    required this.onToggle,
    required this.onLogout,
  });

  final List<AdminSidebarItem> items;
  final String selected;
  final bool collapsed;
  final ValueChanged<String> onSelect;
  final VoidCallback onToggle;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: collapsed ? 76 : 238,
      color: Colors.white,
      child: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              const CircleAvatar(backgroundColor: StudyHubColors.darkGreen, child: Icon(Icons.admin_panel_settings, color: Colors.white)),
              if (!collapsed) ...[
                const SizedBox(width: 10),
                const Expanded(child: Text('StudyHub Admin', style: TextStyle(fontWeight: FontWeight.w900))),
              ],
            ]),
          ),
          IconButton(onPressed: onToggle, icon: Icon(collapsed ? Icons.chevron_right : Icons.chevron_left)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: items.map((item) {
                final active = selected == item.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    dense: true,
                    selected: active,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    selectedTileColor: StudyHubColors.softGreen,
                    leading: Icon(item.icon, color: active ? StudyHubColors.orange : StudyHubColors.darkGreen),
                    title: collapsed ? null : Text(item.label, style: TextStyle(fontWeight: FontWeight.w800, color: active ? StudyHubColors.darkGreen : StudyHubColors.text, fontSize: 12)),
                    onTap: () => item.key == 'logout' ? onLogout() : onSelect(item.key),
                  ),
                );
              }).toList(),
            ),
          ),
        ]),
      ),
    );
  }
}

class AdminHeader extends StatelessWidget {
  const AdminHeader({super.key, required this.title, required this.adminName, required this.photoUrl, required this.onNotifications, required this.onLogout});
  final String title;
  final String adminName;
  final String? photoUrl;
  final VoidCallback onNotifications;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: StudyHubColors.line))),
      child: Row(children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const Spacer(),
        IconButton.filledTonal(tooltip: 'Notifications', onPressed: onNotifications, icon: const Icon(Icons.notifications_outlined)),
        const SizedBox(width: 10),
        CircleAvatar(
          backgroundColor: StudyHubColors.orange,
          backgroundImage: photoUrl == null ? null : NetworkImage(photoUrl!),
          child: photoUrl == null ? Text(adminName.isEmpty ? 'A' : adminName.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)) : null,
        ),
        const SizedBox(width: 10),
        Text(adminName, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(width: 8),
        IconButton(tooltip: 'Logout', onPressed: onLogout, icon: const Icon(Icons.logout, color: StudyHubColors.error)),
      ]),
    );
  }
}

class AdminStatCard extends StatelessWidget {
  const AdminStatCard({super.key, required this.label, required this.value, required this.icon, this.orange = false});
  final String label;
  final String value;
  final IconData icon;
  final bool orange;

  @override
  Widget build(BuildContext context) {
    final color = orange ? StudyHubColors.orange : StudyHubColors.darkGreen;
    return Container(
      width: 190,
      height: 118,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: StudyHubColors.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(radius: 18, backgroundColor: color.withOpacity(.12), child: Icon(icon, color: color, size: 19)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: StudyHubColors.secondaryText, fontSize: 12)),
      ]),
    );
  }
}

class AdminFilterBar extends StatelessWidget {
  const AdminFilterBar({super.key, required this.query, required this.onQuery, required this.filters, required this.selectedFilter, required this.onFilter});
  final String query;
  final ValueChanged<String> onQuery;
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilter;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
        width: 320,
        child: TextField(
          onChanged: onQuery,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search records...', filled: true, fillColor: Colors.white),
        ),
      ),
      const SizedBox(width: 12),
      Wrap(
        spacing: 8,
        children: filters.map((filter) {
          final active = selectedFilter == filter;
          return ChoiceChip(label: Text(filter), selected: active, onSelected: (_) => onFilter(filter));
        }).toList(),
      ),
    ]);
  }
}

class AdminActionButtons extends StatelessWidget {
  const AdminActionButtons({super.key, required this.onView, required this.onEdit, required this.onDelete, this.extra = const []});
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final List<Widget> extra;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      ...extra,
      IconButton(tooltip: 'View Details', onPressed: onView, icon: const Icon(Icons.visibility_outlined)),
      IconButton(tooltip: 'Edit', onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
      IconButton(tooltip: 'Delete', onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: StudyHubColors.error)),
    ]);
  }
}

class AdminTable extends StatelessWidget {
  const AdminTable({super.key, required this.columns, required this.rows, required this.cellBuilder, required this.actionBuilder});
  final List<String> columns;
  final List<dynamic> rows;
  final List<String> Function(dynamic row) cellBuilder;
  final Widget Function(dynamic row) actionBuilder;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: StudyHubColors.line)),
      child: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
              columns: [...columns.map((label) => DataColumn(label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)))), const DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w900)))],
              rows: rows.map((row) {
                final values = cellBuilder(row);
                return DataRow(cells: [
                  ...values.map((value) => DataCell(SizedBox(width: 145, child: Text(value, maxLines: 2, overflow: TextOverflow.ellipsis)))),
                  DataCell(actionBuilder(row)),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminChartCard extends StatelessWidget {
  const AdminChartCard({super.key, required this.title, required this.values});
  final String title;
  final Map<String, dynamic> values;

  @override
  Widget build(BuildContext context) {
    final max = values.values.fold<double>(1, (value, item) => (double.tryParse(item.toString()) ?? 0) > value ? (double.tryParse(item.toString()) ?? 0) : value);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: StudyHubColors.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        ...values.entries.map((entry) {
          final amount = double.tryParse(entry.value.toString()) ?? 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              SizedBox(width: 110, child: Text(entry.key, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
              Expanded(child: LinearProgressIndicator(value: amount / max, minHeight: 8, color: StudyHubColors.orange, backgroundColor: StudyHubColors.softGreen)),
              const SizedBox(width: 10),
              Text(amount.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.w900)),
            ]),
          );
        }),
      ]),
    );
  }
}
