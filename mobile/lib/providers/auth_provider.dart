import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider.empty();

  AuthService? _service;
  User? user;
  bool loading = false;
  String? error;
  Map<String, int> stats = const {'bookings_count': 0, 'favorites_count': 0, 'reviews_count': 0};

  bool get isAuthenticated => user != null;

  void attach(AuthService service) => _service = service;

  Future<void> bootstrap() async {
    loading = true;
    notifyListeners();
    try {
      final token = await _service!.loadToken();
      user = token == null ? null : await _service!.me();
      if (user != null) stats = await _service!.stats();
    } catch (_) {
      user = null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    return _guard(() async => user = await _service!.login(email, password));
  }

  Future<bool> register(String name, String email, String phone, String password, String role, String city, String university) async {
    return _guard(() async => await _service!.register(name, email, phone, password, role, city, university));
  }

  Future<void> loadStats() async {
    if (user == null) return;
    stats = await _service!.stats();
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> body) async {
    return _guard(() async => user = await _service!.updateProfile(body));
  }

  Future<bool> uploadProfilePhoto(File file) async {
    return _guard(() async => user = await _service!.uploadProfilePhoto(file));
  }

  Future<bool> addWhatsappNumber(String countryCode, String number) async {
    return _guard(() async {
      await _service!.addWhatsappNumber(countryCode, number);
      user = await _service!.me();
    });
  }

  Future<bool> updateWhatsappNumber(int id, String countryCode, String number) async {
    return _guard(() async {
      await _service!.updateWhatsappNumber(id, countryCode, number);
      user = await _service!.me();
    });
  }

  Future<bool> deleteWhatsappNumber(int id) async {
    return _guard(() async {
      await _service!.deleteWhatsappNumber(id);
      user = await _service!.me();
    });
  }

  Future<void> logout() async {
    await _service!.logout();
    user = null;
    notifyListeners();
  }

  Future<bool> _guard(Future<void> Function() action) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (exception) {
      error = exception.toString();
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
