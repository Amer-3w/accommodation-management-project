import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../models/property.dart';
import '../../repositories/property_repository.dart';
import '../../widgets/EduStay_components.dart';
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
    try {
      final userId = context.read<AuthProvider>().user?.id;
      final json = await context
          .read<PropertyRepository>()
          .list({'owner_id': userId?.toString() ?? ''});

      final List<dynamic> rawList = (json is Map && json['data'] is List)
          ? json['data'] as List<dynamic>
          : (json is List ? json as List<dynamic> : []);

      final List<Property> parsedProperties = [];

      for (var item in rawList) {
        try {
          if (item is Map) {
            final map = Map<String, dynamic>.from(item);

            if (map['images'] is List && (map['images'] as List).isNotEmpty) {
              final List<dynamic> imgList = map['images'] as List<dynamic>;
              final List<String> stringUrls = [];
              for (var img in imgList) {
                if (img is Map) {
                  final urlStr = img['url'] ?? img['image_url'] ?? img['path'];
                  if (urlStr != null) stringUrls.add(urlStr.toString());
                } else if (img != null) {
                  stringUrls.add(img.toString());
                }
              }
              map['images'] = stringUrls;
            }

            if (map['images'] == null ||
                (map['images'] is List && (map['images'] as List).isEmpty)) {
              map['images'] = ['https://picsum.photos'];
            }

            parsedProperties.add(Property.fromJson(map));
          } else {
            parsedProperties.add(Property.fromJson(item));
          }
        } catch (_) {
          try {
            parsedProperties.add(Property.fromJson(item));
          } catch (__) {}
        }
      }

      if (mounted) {
        setState(() {
          properties = parsedProperties;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = loading
        ? const Center(child: CircularProgressIndicator())
        : properties.isEmpty
            ? const Center(child: Text('No properties yet.'))
            : LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: constraints.maxWidth,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(14),
                      itemBuilder: (_, index) {
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 92,
                            child: FigmaPropertyCard(
                              property: properties[index],
                              onTap: () async {
                                await Navigator.pushNamed(
                                    context, OwnerPropertyFormScreen.route,
                                    arguments: properties[index]);
                                load();
                              },
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: properties.length,
                    ),
                  );
                },
              );

    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('My Properties'), actions: [
        IconButton(
            onPressed: () async {
              await Navigator.pushNamed(context, OwnerPropertyFormScreen.route);
              load();
            },
            icon: const Icon(Icons.add))
      ]),
      body: body,
    );
  }
}
