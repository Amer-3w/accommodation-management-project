import '../core/utils/json_parsers.dart';

class Property {
  const Property({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.description,
    required this.ownerId,
    required this.rating,
    required this.rooms,
    required this.images,
    required this.amenities,
    this.imageRecords = const [],
    this.priceDuration = 'month',
    this.stayDuration = 1,
    this.propertyType = 'Apartment',
    this.rules = const [],
    this.contactEmail,
    this.contactWhatsappCountryCode,
    this.contactWhatsappNumber,
    this.contactType = 'email',
    this.latitude,
    this.longitude,
    this.governorate,
    this.city,
    this.university,
    this.address,
    this.ownerName,
    this.ownerWhatsapp,
    this.reviewCount = 0,
    this.reviews = const [],
    this.isBooked = false,
  });

  final int id;
  final String title;
  final double price;
  final String location;
  final String description;
  final int ownerId;
  final double rating;
  final int rooms;
  final List<String> images;
  final List<String> amenities;
  final List<PropertyImageRecord> imageRecords;
  final String priceDuration;
  final int stayDuration;
  final String propertyType;
  final List<String> rules;
  final String? contactEmail;
  final String? contactWhatsappCountryCode;
  final String? contactWhatsappNumber;
  final String contactType;
  final double? latitude;
  final double? longitude;
  final String? governorate;
  final String? city;
  final String? university;
  final String? address;
  final String? ownerName;
  final String? ownerWhatsapp;
  final int reviewCount;
  final List<PropertyReview> reviews;
  final bool isBooked;

  factory Property.fromJson(Map<String, dynamic> json) {
    // Safely extract string image URLs from lists of strings or lists of maps
    final List<String> extractedImages = [];
    if (json['images'] != null && json['images'] is List) {
      for (var item in json['images']) {
        if (item is Map) {
          final urlStr = item['url'] ??
              item['image_url'] ??
              item['path'] ??
              item['image_path'];
          if (urlStr != null) extractedImages.add(urlStr.toString());
        } else if (item != null) {
          extractedImages.add(item.toString());
        }
      }
    }

    // Fallback placeholder image if no images exist anywhere in the database record
    if (extractedImages.isEmpty) {
      extractedImages.add('https://picsum.photos');
    }

    return Property(
      id: parseInt(json['id']),
      title: parseString(json['title']),
      price: parseDouble(json['price']),
      location: parseString(json['location']),
      description: json['description'] ?? '',
      ownerId: parseInt(json['owner_id']),
      rating: parseDouble(json['rating']),
      rooms: parseInt(json['rooms'], fallback: 1),
      images: extractedImages, // Use the safely parsed list
      amenities: List<String>.from(json['amenities'] ?? const []),
      imageRecords: (json['image_records'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PropertyImageRecord.fromJson)
          .toList(),
      priceDuration: json['price_duration'] ?? 'month',
      stayDuration: parseInt(json['stay_duration'], fallback: 1),
      propertyType: json['property_type'] ?? 'Apartment',
      rules: List<String>.from(json['rules'] ?? const []),
      contactEmail: json['contact_email'],
      contactWhatsappCountryCode: json['contact_whatsapp_country_code'],
      contactWhatsappNumber: json['contact_whatsapp_number'],
      contactType: json['contact_type'] ?? 'email',
      latitude: json['latitude'] == null ? null : parseDouble(json['latitude']),
      longitude:
          json['longitude'] == null ? null : parseDouble(json['longitude']),
      governorate: json['governorate'],
      city: json['city'],
      university: json['university'],
      address: json['address'],
      ownerName: json['owner_name'],
      ownerWhatsapp: json['owner_whatsapp'],
      reviewCount: parseInt(json['review_count']),
      reviews: (json['reviews'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PropertyReview.fromJson)
          .toList(),
      isBooked: json['is_booked'] == true || json['is_booked'] == 1,
    );
  }
}

class PropertyImageRecord {
  const PropertyImageRecord({required this.id, required this.url});
  final int id;
  final String url;

  factory PropertyImageRecord.fromJson(Map<String, dynamic> json) =>
      PropertyImageRecord(
        id: parseInt(json['id']),
        url: parseString(json['url']),
      );
}

class PropertyReview {
  const PropertyReview({
    required this.id,
    required this.userName,
    required this.rating,
    this.comment,
    this.ownerReply,
    this.createdAt,
  });

  final int id;
  final String userName;
  final int rating;
  final String? comment;
  final String? ownerReply;
  final String? createdAt;

  factory PropertyReview.fromJson(Map<String, dynamic> json) => PropertyReview(
        id: parseInt(json['id']),
        userName: json['user_name'] ?? 'Student',
        rating: parseInt(json['rating']),
        comment: json['comment'],
        ownerReply: json['owner_reply'],
        createdAt: json['created_at'],
      );
}
