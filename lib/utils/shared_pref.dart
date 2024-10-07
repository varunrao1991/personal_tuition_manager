import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> clear(String key) async {
    await init();
    await _sharedPrefs!.remove(key);
  }
}

final sharedPrefs = SharedPrefs();
