import '../models/booking.dart';
import '../repositories/booking_repository.dart';
import '../core/utils/json_parsers.dart';

class BookingService {
  BookingService(this._repository);

  final BookingRepository _repository;

  Future<List<Booking>> mine() async {
    final json = await _repository.list();
    return asListData(json).whereType<Map<String, dynamic>>().map(Booking.fromJson).toList();
  }

  Future<Booking> create({
    required int propertyId,
    required DateTime from,
    required DateTime to,
    required int guests,
  }) async {
    final json = await _repository.create({
      'property_id': propertyId,
      'date_from': from.toIso8601String().substring(0, 10),
      'date_to': to.toIso8601String().substring(0, 10),
      'guests': guests,
    });
    return Booking.fromJson(asMapData(json));
  }

  Future<Booking> details(int id) async {
    final json = await _repository.details(id);
    return Booking.fromJson(asMapData(json));
  }

  Future<Booking> update(int id, DateTime from, DateTime to, int guests, String? notes) async {
    final json = await _repository.update(id, {
      'date_from': from.toIso8601String().substring(0, 10),
      'date_to': to.toIso8601String().substring(0, 10),
      'guests': guests,
      'notes': notes,
    });
    return Booking.fromJson(asMapData(json));
  }

  Future<Booking> cancel(int id) async => Booking.fromJson(asMapData(await _repository.cancel(id)));
  Future<void> delete(int id) async => _repository.delete(id);
  Future<Booking> status(int id, String status) async => Booking.fromJson(asMapData(await _repository.status(id, status)));
}
