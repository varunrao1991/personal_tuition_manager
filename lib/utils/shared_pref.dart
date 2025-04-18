import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefs {
  SharedPreferences? _sharedPrefs;

  Future<void> init() async {
    _sharedPrefs ??= await SharedPreferences.getInstance();
  }

  Future<void> saveString(String key, String value) async {
    await init();
    await _sharedPrefs!.setString(key, value);
  }

  Future<String?> getString(String key) async {
    await init();
    return _sharedPrefs!.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await init();
    await _sharedPrefs!.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    await init();
    return _sharedPrefs!.getBool(key);
  }

  Future<void> clear(String key) async {
    await init();
    await _sharedPrefs!.remove(key);
  }

  Future<void> saveStringMap(String key, Map<String, String> map) async {
    await init(); // Ensure _sharedPrefs is initialized
    await _sharedPrefs!.setString(key, json.encode(map));
  }

  Future<Map<String, String>> getStringMap(String key) async {
    await init(); // Ensure _sharedPrefs is initialized
    final jsonString = _sharedPrefs!.getString(key);
    if (jsonString == null) return {};
    try {
      final map = json.decode(jsonString) as Map<String, dynamic>;
      return map.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      return {};
    }
  }
}

final sharedPrefs = SharedPrefs();