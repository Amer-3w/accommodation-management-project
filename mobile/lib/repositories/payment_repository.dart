import '../core/network/api_client.dart';

class PaymentRepository {
  PaymentRepository(this.api);

  final ApiClient api;

  Future<Map<String, dynamic>> pay(int bookingId, String method) => api.post('/payments', {'booking_id': bookingId, 'method': method});
}
