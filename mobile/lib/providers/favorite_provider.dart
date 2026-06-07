import 'package:flutter/foundation.dart';

import '../models/property.dart';
import '../services/favorite_service.dart';

class FavoriteProvider extends ChangeNotifier {
  FavoriteProvider.empty();

  FavoriteService? _service;
  List<Property> favorites = [];

  Set<int> get ids => favorites.map((item) => item.id).toSet();

  void attach(FavoriteService service) => _service = service;

  Future<void> load() async {
    favorites = await _service!.list();
    notifyListeners();
  }

  Future<void> toggle(Property property) async {
    await _service!.toggle(property.id);
    if (ids.contains(property.id)) {
      favorites = favorites.where((item) => item.id != property.id).toList();
    } else {
      favorites = [...favorites, property];
    }
    notifyListeners();
  }
}
