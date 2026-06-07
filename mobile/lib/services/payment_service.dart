import '../repositories/payment_repository.dart';

class PaymentService {
  PaymentService(this._repository);

  final PaymentRepository _repository;

  Future<Map<String, dynamic>> pay({
    required int bookingId,
    required String method,
  }) {
    return _repository.pay(bookingId, method);
  }
}
