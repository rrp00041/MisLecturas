import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mis_lecturas/app.dart';
import 'package:mis_lecturas/core/providers/app_providers.dart';

void main() {
  testWidgets('app renders login screen by default', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(
            await SharedPreferences.getInstance(),
          ),
        ],
        child: const MyLibraryApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('MisLecturas'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
