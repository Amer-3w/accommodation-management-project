import '../core/utils/json_parsers.dart';

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.city,
    this.university,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.bio,
    this.profilePhotoUrl,
    this.whatsappNumbers = const [],
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? city;
  final String? university;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? bio;
  final String? profilePhotoUrl;
  final List<WhatsappNumber> whatsappNumbers;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: parseInt(json['id']),
        name: parseString(json['name']),
        email: parseString(json['email']),
        role: json['role'] ?? 'user',
        phone: json['phone'],
        city: json['city'],
        university: json['university'],
        dateOfBirth: json['date_of_birth'],
        gender: json['gender'],
        address: json['address'],
        bio: json['bio'],
        profilePhotoUrl: json['profile_photo_url'],
        whatsappNumbers: (json['whatsapp_numbers'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(WhatsappNumber.fromJson)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'phone': phone,
        'city': city,
        'university': university,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'address': address,
        'bio': bio,
        'profile_photo_url': profilePhotoUrl,
        'whatsapp_numbers': whatsappNumbers.map((item) => item.toJson()).toList(),
      };
}

class WhatsappNumber {
  const WhatsappNumber({
    required this.id,
    required this.countryCode,
    required this.number,
  });

  final int id;
  final String countryCode;
  final String number;

  String get formatted => '$countryCode$number';

  factory WhatsappNumber.fromJson(Map<String, dynamic> json) => WhatsappNumber(
        id: parseInt(json['id']),
        countryCode: parseString(json['country_code']),
        number: parseString(json['number']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'country_code': countryCode,
        'number': number,
      };
}
