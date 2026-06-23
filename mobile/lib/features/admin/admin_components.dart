import 'package:flutter/material.dart';

import '../../core/theme/EduStay_design.dart';

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
              const CircleAvatar(
                  backgroundColor: EduStayColors.darkGreen,
                  child: Icon(Icons.admin_panel_settings, color: Colors.white)),
              if (!collapsed) ...[
                const SizedBox(width: 10),
                const Expanded(
                    child: Text('EduStay Admin',
                        style: TextStyle(fontWeight: FontWeight.w900))),
              ],
            ]),
          ),
          IconButton(
              onPressed: onToggle,
              icon: Icon(collapsed ? Icons.chevron_right : Icons.chevron_left)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: items.map((item) {
                final active = selected == item.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Container(
                    // Enforces solid background separation bounds
                    decoration: BoxDecoration(
                      color:
                          active ? EduStayColors.softGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      dense: true,
                      selected: active,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      // FIXED: Wrapped the leading icon inside a static size frame to stop it consuming tile width
                      leading: SizedBox(
                        width: 24,
                        height: 24,
                        child: Icon(item.icon,
                            size: 20,
                            color: active
                                ? EduStayColors.orange
                                : EduStayColors.darkGreen),
                      ),
                      title: collapsed
                          ? null
                          : Text(item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: active
                                      ? EduStayColors.darkGreen
                                      : EduStayColors.text,
                                  fontSize: 12)),
                      onTap: () => item.key == 'logout'
                          ? onLogout()
                          : onSelect(item.key),
                    ),
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
  const AdminHeader(
      {super.key,
      required this.title,
      required this.adminName,
      required this.photoUrl,
      required this.onNotifications,
      required this.onLogout,
      required this.onSelect});
  final String title;
  final String adminName;
  final String? photoUrl;
  final VoidCallback onNotifications;
  final VoidCallback onLogout;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(
          horizontal: 12), // Reduced from 22 to save space
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: EduStayColors.line))),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Using FittedBox ensures the tab name text shrinks instead of pushing icons off-screen
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900)),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onNotifications,
                    icon: const Icon(Icons.notifications_outlined, size: 20)),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => onSelect('settings'),
                  borderRadius: BorderRadius.circular(100),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: EduStayColors.orange,
                    backgroundImage:
                        photoUrl == null ? null : NetworkImage(photoUrl!),
                    child: photoUrl == null
                        ? Text(
                            adminName.isEmpty
                                ? 'A'
                                : adminName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 12))
                        : null,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout,
                        color: EduStayColors.error, size: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AdminStatCard extends StatelessWidget {
  const AdminStatCard(
      {super.key,
      required this.label,
      required this.value,
      required this.icon,
      this.orange = false});
  final String label;
  final String value;
  final IconData icon;
  final bool orange;

  @override
  Widget build(BuildContext context) {
    final color = orange ? EduStayColors.orange : EduStayColors.darkGreen;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: EduStayColors.line)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
              radius: 14,
              backgroundColor: color.withOpacity(.12),
              child: Icon(icon, color: color, size: 16)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: EduStayColors.secondaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class AdminFilterBar extends StatelessWidget {
  const AdminFilterBar(
      {super.key,
      required this.query,
      required this.onQuery,
      required this.filters,
      required this.selectedFilter,
      required this.onFilter});
  final String query;
  final ValueChanged<String> onQuery;
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilter;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 200, // Keeps search bar compact across all tabs
            child: TextField(
              onChanged: onQuery,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search records...',
                  filled: true,
                  fillColor: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Wrap(
            spacing: 8,
            children: filters.map((filter) {
              final active = selectedFilter == filter;
              return ChoiceChip(
                  label: Text(filter),
                  selected: active,
                  onSelected: (_) => onFilter(filter));
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class AdminActionButtons extends StatelessWidget {
  const AdminActionButtons(
      {super.key,
      required this.onView,
      required this.onEdit,
      required this.onDelete,
      this.extra = const []});
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final List<Widget> extra;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      ...extra,
      IconButton(
          tooltip: 'View Details',
          onPressed: onView,
          icon: const Icon(Icons.visibility_outlined)),
      IconButton(
          tooltip: 'Edit',
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined)),
      IconButton(
          tooltip: 'Delete',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, color: EduStayColors.error)),
    ]);
  }
}

class AdminTable extends StatelessWidget {
  const AdminTable(
      {super.key,
      required this.columns,
      required this.rows,
      required this.cellBuilder,
      required this.actionBuilder});
  final List<String> columns;
  final List<dynamic> rows;
  final List<String> Function(dynamic row) cellBuilder;
  final Widget Function(dynamic row) actionBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: EduStayColors.line)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Theme(
          data: Theme.of(context).copyWith(
            dataTableTheme: const DataTableThemeData(
              headingRowHeight: 44,
              dataRowMinHeight: 48,
              dataRowMaxHeight: 60,
              horizontalMargin: 12,
              columnSpacing: 14,
            ),
          ),
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor:
                      WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                  columns: [
                    ...columns.map((label) => DataColumn(
                        label: Text(label,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 12)))),
                    const DataColumn(
                        label: Text('Actions',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 12)))
                  ],
                  rows: rows.map((row) {
                    final values = cellBuilder(row);
                    return DataRow(cells: [
                      ...values.map((value) => DataCell(
                            Container(
                              constraints: const BoxConstraints(maxWidth: 100),
                              child: Text(
                                value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ),
                          )),
                      DataCell(actionBuilder(row)),
                    ]);
                  }).toList(),
                ),
              ),
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
    final max = values.values.fold<double>(
        1,
        (value, item) => (double.tryParse(item.toString()) ?? 0) > value
            ? (double.tryParse(item.toString()) ?? 0)
            : value);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: EduStayColors.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        const SizedBox(height: 12),
        ...values.entries.map((entry) {
          final amount = double.tryParse(entry.value.toString()) ?? 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(entry.key,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                      value: amount / max,
                      minHeight: 6,
                      color: EduStayColors.orange,
                      backgroundColor: EduStayColors.softGreen)),
              const SizedBox(width: 8),
              Text(amount.toStringAsFixed(0),
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 11)),
            ]),
          );
        }),
      ]),
    );
  }
}
