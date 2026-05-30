import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesNotifier extends ChangeNotifier {
  static const _currencyKey = 'currency_code';

  final SharedPreferences _prefs;
  String _currencyCode;

  String get currencyCode => _currencyCode;

  PreferencesNotifier(this._prefs)
      : _currencyCode = _prefs.getString(_currencyKey) ?? 'BRL';

  Future<void> setCurrency(String code) async {
    _currencyCode = code;
    notifyListeners();
    await _prefs.setString(_currencyKey, code);
  }

  static String labelFor(String code) {
    const labels = {'BRL': 'BRL (R\$)', 'USD': 'USD (\$)', 'EUR': 'EUR (€)'};
    return labels[code] ?? code;
  }
}
