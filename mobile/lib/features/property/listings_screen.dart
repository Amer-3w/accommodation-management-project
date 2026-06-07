import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/favorite_provider.dart';
import '../../providers/property_provider.dart';
import '../../widgets/studyhub_components.dart';
import '../search/search_screen.dart';
import 'property_details_screen.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key, this.embedded = false});
  static const route = '/listings';

  final bool embedded;

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().load();
      context.read<FavoriteProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PropertyProvider>();
    final favorites = context.watch<FavoriteProvider>();
    return Scaffold(
      appBar: widget.embedded
          ? null
          : AppBar(
              title: const Text('Properties'),
              actions: [IconButton(onPressed: () => Navigator.pushNamed(context, SearchScreen.route), icon: const Icon(Icons.tune))],
            ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            if (widget.embedded)
              Row(children: [
                const Expanded(child: Text('Properties', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
                IconButton(onPressed: () => Navigator.pushNamed(context, SearchScreen.route), icon: const Icon(Icons.tune)),
              ]),
            Text('${provider.properties.length} properties found'),
            const SizedBox(height: 14),
            if (provider.loading) const Center(child: CircularProgressIndicator()),
            ...provider.properties.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: FadeSlideIn(
                    delay: Duration(milliseconds: entry.key * 45),
                    child: FigmaPropertyCard(
                      property: entry.value,
                      favorite: favorites.ids.contains(entry.value.id),
                      onFavorite: () => context.read<FavoriteProvider>().toggle(entry.value),
                      onTap: () => Navigator.pushNamed(context, PropertyDetailsScreen.route, arguments: entry.value.id),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
