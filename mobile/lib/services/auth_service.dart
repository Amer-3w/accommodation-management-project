import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/api_client.dart';
import '../core/utils/json_parsers.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

class AuthService {
  AuthService(this._apiClient, this._repository);

  final ApiClient _apiClient;
  final AuthRepository _repository;
  static const _tokenKey = 'studyhub_token';

  Future<String?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    _apiClient.setToken(token);
    return token;
  }

  Future<User?> me() async {
    final json = await _repository.me();
    return User.fromJson(asMapData(json));
  }

  Future<User> login(String email, String password) async {
    final json = await _repository.login({'email': email, 'password': password});
    await _persistToken(json['token']);
    return User.fromJson(json['user']);
  }

  Future<User> register(String name, String email, String phone, String password, String role, String city, String university) async {
    final json = await _repository.register({
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': password,
      'role': role,
      'city': city,
      'university': university,
    });
    return User.fromJson(json['user']);
  }

  Future<Map<String, int>> stats() async {
    final json = await _repository.stats();
    final data = asMapData(json);
    return {
      'bookings_count': parseInt(data['bookings_count']),
      'favorites_count': parseInt(data['favorites_count']),
      'reviews_count': parseInt(data['reviews_count']),
    };
  }

  Future<User> updateProfile(Map<String, dynamic> body) async {
    final json = await _repository.updateProfile(body);
    return User.fromJson(asMapData(json['user'] ?? json));
  }

  Future<User> uploadProfilePhoto(File file) async {
    final json = await _repository.uploadProfilePhoto(file);
    return User.fromJson(asMapData(json['user'] ?? json));
  }

  Future<void> addWhatsappNumber(String countryCode, String number) async {
    await _repository.addWhatsappNumber({'country_code': countryCode, 'number': number});
  }

  Future<void> updateWhatsappNumber(int id, String countryCode, String number) async {
    await _repository.updateWhatsappNumber(id, {'country_code': countryCode, 'number': number});
  }

  Future<void> deleteWhatsappNumber(int id) async {
    await _repository.deleteWhatsappNumber(id);
  }

  Future<void> logout() async {
    await _repository.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _apiClient.setToken(null);
  }

  Future<void> forgotPassword(String email) async {
    await _repository.forgotPassword(email);
  }

  Future<void> _persistToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _apiClient.setToken(token);
  }
}
