import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../models/property.dart';
import '../../repositories/property_repository.dart';
import '../../widgets/studyhub_components.dart';
import 'owner_property_form_screen.dart';

class OwnerPropertiesScreen extends StatefulWidget {
  const OwnerPropertiesScreen({super.key, this.embedded = false});
  static const route = '/owner-properties';
  final bool embedded;

  @override
  State<OwnerPropertiesScreen> createState() => _OwnerPropertiesScreenState();
}

class _OwnerPropertiesScreenState extends State<OwnerPropertiesScreen> {
  List<Property> properties = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final userId = context.read<AuthProvider>().user?.id;
    final json = await context.read<PropertyRepository>().list({'owner_id': userId?.toString() ?? ''});
    setState(() {
      properties = (json['data'] as List<dynamic>? ?? json as List<dynamic>).map((item) => Property.fromJson(item)).toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = loading
          ? const Center(child: CircularProgressIndicator())
          : properties.isEmpty
              ? const Center(child: Text('No properties yet.'))
              : ListView.separated(
              padding: const EdgeInsets.all(18),
              itemBuilder: (_, index) => FigmaPropertyCard(
                property: properties[index],
                onTap: () async {
                  await Navigator.pushNamed(context, OwnerPropertyFormScreen.route, arguments: properties[index]);
                  load();
                },
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemCount: properties.length,
            );
    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('My Properties'), actions: [IconButton(onPressed: () async { await Navigator.pushNamed(context, OwnerPropertyFormScreen.route); load(); }, icon: const Icon(Icons.add))]),
      body: body,
    );
  }
}
