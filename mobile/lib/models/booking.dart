import '../core/utils/json_parsers.dart';

class Booking {
  const Booking({
    required this.id,
    required this.propertyId,
    required this.dateFrom,
    required this.dateTo,
    required this.status,
    this.guests = 1,
    this.notes,
    this.propertyTitle,
    this.propertyLocation,
    this.propertyPrice,
    this.propertyImage,
    this.basePrice = 0,
    this.pricePeriod = 'month',
    this.numberOfDays = 1,
    this.baseTotal = 0,
    this.discountPercent = 0,
    this.discountAmount = 0,
    this.serviceFee = 0,
    this.securityDeposit = 0,
    this.finalTotal = 0,
  });

  final int id;
  final int propertyId;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String status;
  final int guests;
  final String? notes;
  final String? propertyTitle;
  final String? propertyLocation;
  final double? propertyPrice;
  final String? propertyImage;
  final double basePrice;
  final String pricePeriod;
  final int numberOfDays;
  final double baseTotal;
  final double discountPercent;
  final double discountAmount;
  final double serviceFee;
  final double securityDeposit;
  final double finalTotal;

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: parseInt(json['id']),
        propertyId: parseInt(json['property_id']),
        dateFrom: DateTime.parse(json['date_from']),
        dateTo: DateTime.parse(json['date_to']),
        status: parseString(json['status'], fallback: 'pending'),
        guests: parseInt(json['guests'], fallback: 1),
        notes: json['notes'],
        propertyTitle: json['property']?['title'],
        propertyLocation: json['property']?['location'],
        propertyPrice: json['property']?['price'] == null ? null : parseDouble(json['property']['price']),
        propertyImage: json['property']?['images'] is List && (json['property']['images'] as List).isNotEmpty ? json['property']['images'][0]?.toString() : null,
        basePrice: parseDouble(json['base_price']),
        pricePeriod: parseString(json['price_period'], fallback: 'month'),
        numberOfDays: parseInt(json['number_of_days'], fallback: 1),
        baseTotal: parseDouble(json['base_total']),
        discountPercent: parseDouble(json['discount_percent']),
        discountAmount: parseDouble(json['discount_amount']),
        serviceFee: parseDouble(json['service_fee']),
        securityDeposit: parseDouble(json['security_deposit']),
        finalTotal: parseDouble(json['final_total']),
      );
}
