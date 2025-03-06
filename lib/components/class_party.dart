import 'dart:convert';

class Party {
  final String title;
  final String description;
  final String place;
  final String address;
  final String date;
  final String time;

  Party({
    required this.title,
    required this.description,
    required this.place,
    required this.address,
    required this.date,
    required this.time,
  });

  // Преобразуем объект в Map (для сохранения)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description, // Порядок не важен, но для ясности
      'place': place,
      'address': address,
      'date': date,
      'time': time,
    };
  }

  // Создаём объект из Map
  factory Party.fromMap(Map<String, dynamic> map) {
    return Party(
      title: map['title'] ?? '', // На случай, если ключа нет
      description: map['description'] ?? '',
      place: map['place'] ?? '',
      address: map['address'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
    );
  }

  // Преобразуем объект в JSON-строку
  String toJson() => json.encode(toMap());

  // Создаём объект из JSON-строки
  factory Party.fromJson(String source) => Party.fromMap(json.decode(source));
}
