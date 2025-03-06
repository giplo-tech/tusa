import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'class_party.dart';

class PartyStorage {
  static const String _key = 'parties';

  // Загрузка списка мероприятий
  static Future<List<Party>> loadParties() async {
    final prefs = await SharedPreferences.getInstance();
    final String? partiesJson = prefs.getString(_key);
    if (partiesJson != null) {
      final List<dynamic> decoded = jsonDecode(partiesJson);
      return decoded.map((item) => Party.fromJson(item)).toList();
    }
    return [];
  }

  // Сохранение списка мероприятий
  static Future<void> saveParties(List<Party> parties) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(parties.map((party) => party.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}