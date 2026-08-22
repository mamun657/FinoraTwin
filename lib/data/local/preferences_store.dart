import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override in main()'),
);

class PreferencesStore {
  PreferencesStore(this._prefs);
  final SharedPreferences _prefs;

  static const _kApiBaseUrl = 'api_base_url';
  static const _kSelectedBusinessId = 'selected_business_id';
  static const _kOnboardingComplete = 'onboarding_complete';

  String? get apiBaseUrl => _prefs.getString(_kApiBaseUrl);
  Future<void> setApiBaseUrl(String value) =>
      _prefs.setString(_kApiBaseUrl, value);

  String? get selectedBusinessId => _prefs.getString(_kSelectedBusinessId);
  Future<void> setSelectedBusinessId(String? value) async {
    if (value == null) {
      await _prefs.remove(_kSelectedBusinessId);
    } else {
      await _prefs.setString(_kSelectedBusinessId, value);
    }
  }

  bool get onboardingComplete => _prefs.getBool(_kOnboardingComplete) ?? false;
  Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(_kOnboardingComplete, value);
}

final preferencesStoreProvider = Provider<PreferencesStore>(
  (ref) => PreferencesStore(ref.watch(sharedPreferencesProvider)),
);

final apiBaseUrlProvider = Provider<String>(
  (ref) => throw UnimplementedError('Override in main()'),
);
