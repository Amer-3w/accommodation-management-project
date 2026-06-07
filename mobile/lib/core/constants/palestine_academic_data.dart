class PalestineAcademicData {
  static const cities = [
    'Jerusalem',
    'Ramallah',
    'Nablus',
    'Jenin',
    'Tulkarm',
    'Qalqilya',
    'Bethlehem',
    'Hebron',
    'Jericho',
    'Salfit',
    'Tubas',
    'Gaza',
    'Khan Yunis',
    'Rafah',
    'Deir al-Balah',
    'North Gaza',
  ];

  static const universitiesByCity = {
    'Jerusalem': ['Al-Quds University', 'Bethlehem Bible College - Jerusalem Campus'],
    'Ramallah': ['Birzeit University', 'Palestine Technical College - Ramallah'],
    'Nablus': ['An-Najah National University', 'Al-Quds Open University - Nablus'],
    'Jenin': ['Arab American University', 'Al-Quds Open University - Jenin'],
    'Tulkarm': ['Palestine Technical University - Kadoorie'],
    'Qalqilya': ['Al-Quds Open University - Qalqilya'],
    'Bethlehem': ['Bethlehem University', 'Palestine Ahliya University'],
    'Hebron': ['Hebron University', 'Palestine Polytechnic University'],
    'Jericho': ['Al-Istiqlal University'],
    'Salfit': ['Al-Quds Open University - Salfit'],
    'Tubas': ['Al-Quds Open University - Tubas'],
    'Gaza': ['Islamic University of Gaza', 'Al-Azhar University - Gaza', 'University of Palestine'],
    'Khan Yunis': ['University College of Applied Sciences - Khan Yunis'],
    'Rafah': ['Al-Quds Open University - Rafah'],
    'Deir al-Balah': ['Palestine Technical College - Deir al-Balah'],
    'North Gaza': ['Al-Quds Open University - North Gaza'],
  };

  static List<String> universitiesFor(String? city) => universitiesByCity[city] ?? const [];
}
