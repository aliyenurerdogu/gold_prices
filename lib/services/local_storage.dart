import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveData(String key, List<String> values) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(key, values);
}

Future<List<String>> getData(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getStringList(key) ?? [];
}
