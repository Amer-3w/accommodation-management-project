import 'dart:io';

import '../core/network/api_client.dart';

class AuthRepository {
  AuthRepository(this.api);

  final ApiClient api;

  Future<Map<String, dynamic>> me() => api.get('/auth/me');
  Future<Map<String, dynamic>> stats() => api.get('/me/stats');
  Future<Map<String, dynamic>> login(Map<String, dynamic> body) => api.post('/auth/login', body);
  Future<Map<String, dynamic>> register(Map<String, dynamic> body) => api.post('/auth/register', body);
  Future<Map<String, dynamic>> logout() => api.post('/auth/logout', {});
  Future<Map<String, dynamic>> forgotPassword(String email) => api.post('/forgot-password', {'email': email});
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) => api.put('/auth/me', body);
  Future<Map<String, dynamic>> uploadProfilePhoto(File file) => api.upload('/me/photo', file);
  Future<Map<String, dynamic>> addWhatsappNumber(Map<String, dynamic> body) => api.post('/user-whatsapp-numbers', body);
  Future<Map<String, dynamic>> updateWhatsappNumber(int id, Map<String, dynamic> body) => api.put('/user-whatsapp-numbers/$id', body);
  Future<Map<String, dynamic>> deleteWhatsappNumber(int id) => api.delete('/user-whatsapp-numbers/$id');
}
