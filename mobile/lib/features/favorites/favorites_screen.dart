import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/favorite_provider.dart';
import '../../widgets/studyhub_components.dart';
import '../property/property_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  static const route = '/favorites';

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<FavoriteProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoriteProvider>().favorites;
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favorites.isEmpty
          ? const Center(child: Text('No favorites yet.'))
          : ListView.separated(
        padding: const EdgeInsets.all(18),
        itemBuilder: (_, index) => FadeSlideIn(
          delay: Duration(milliseconds: index * 35),
          child: FigmaPropertyCard(
            property: favorites[index],
            favorite: true,
            onFavorite: () => context.read<FavoriteProvider>().toggle(favorites[index]),
            onTap: () => Navigator.pushNamed(context, PropertyDetailsScreen.route, arguments: favorites[index].id),
          ),
        ),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemCount: favorites.length,
      ),
    );
  }
}
