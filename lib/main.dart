import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/local/app_database.dart';
import 'data/local/preferences_store.dart';
import 'data/remote/api_client.dart';
import 'data/remote/auth_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final secureStorage = AuthStorage();
  final apiBaseUrl = _resolveApiBaseUrl(prefs);
  final apiClient = ApiClient(baseUrl: apiBaseUrl, authStorage: secureStorage);
  final database = AppDatabase.open();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authStorageProvider.overrideWithValue(secureStorage),
        apiClientProvider.overrideWithValue(apiClient),
        appDatabaseProvider.overrideWithValue(database),
        apiBaseUrlProvider.overrideWithValue(apiBaseUrl),
      ],
      child: const FinoraTwinApp(),
    ),
  );
}

String _resolveApiBaseUrl(SharedPreferences prefs) {
  final configured = prefs.getString('api_base_url');
  if (configured != null && configured.isNotEmpty) return configured;
  const fromEnv = String.fromEnvironment('FINORA_API_BASE_URL');
  if (fromEnv.isNotEmpty) return fromEnv;
  return 'http://127.0.0.1:5087';
}
