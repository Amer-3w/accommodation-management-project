double parseDouble(dynamic value, {double fallback = 0.0}) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? fallback;
}

dynamic unwrapData(dynamic value) {
  if (value is Map<String, dynamic> && value.containsKey('data')) {
    return value['data'];
  }
  return value;
}

List<dynamic> asListData(dynamic value) {
  final data = unwrapData(value);
  if (data is List<dynamic>) return data;
  return const [];
}

Map<String, dynamic> asMapData(dynamic value) {
  final data = unwrapData(value);
  if (data is Map<String, dynamic>) return data;
  return <String, dynamic>{};
}

int parseInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

String parseString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}
