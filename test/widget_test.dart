import 'package:finora_twin/app.dart';
import 'package:finora_twin/data/local/preferences_store.dart';
import 'package:finora_twin/data/remote/auth_storage.dart';
import 'package:finora_twin/data/remote/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('FinoraTwinApp boots without exceptions', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final secureStorage = AuthStorage();
    final apiClient = ApiClient(
      baseUrl: 'http://localhost',
      authStorage: secureStorage,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authStorageProvider.overrideWithValue(secureStorage),
          apiClientProvider.overrideWithValue(apiClient),
        ],
        child: const FinoraTwinApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(MaterialApp), findsWidgets);
    await tester.pump(const Duration(seconds: 2));
  });
}
