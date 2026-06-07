import 'package:flutter/foundation.dart';

import '../models/booking.dart';
import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  BookingProvider.empty();

  BookingService? _service;
  List<Booking> bookings = [];
  Booking? latest;
  bool loading = false;

  void attach(BookingService service) => _service = service;

  Future<void> loadMine() async {
    loading = true;
    notifyListeners();
    bookings = await _service!.mine();
    loading = false;
    notifyListeners();
  }

  Future<Booking> create(int propertyId, DateTime from, DateTime to, int guests) async {
    loading = true;
    notifyListeners();
    latest = await _service!.create(propertyId: propertyId, from: from, to: to, guests: guests);
    loading = false;
    notifyListeners();
    return latest!;
  }

  Future<Booking> details(int id) async {
    latest = await _service!.details(id);
    notifyListeners();
    return latest!;
  }

  Future<void> updateBooking(int id, DateTime from, DateTime to, int guests, String? notes) async {
    loading = true;
    notifyListeners();
    latest = await _service!.update(id, from, to, guests, notes);
    bookings = bookings.map((item) => item.id == id ? latest! : item).toList();
    loading = false;
    notifyListeners();
  }

  Future<void> cancelBooking(int id) async {
    final updated = await _service!.cancel(id);
    bookings = bookings.map((item) => item.id == id ? updated : item).toList();
    notifyListeners();
  }

  Future<void> deleteBooking(int id) async {
    await _service!.delete(id);
    bookings = bookings.where((item) => item.id != id).toList();
    notifyListeners();
  }

  Future<void> changeStatus(int id, String status) async {
    final updated = await _service!.status(id, status);
    bookings = bookings.map((item) => item.id == id ? updated : item).toList();
    notifyListeners();
  }
}
