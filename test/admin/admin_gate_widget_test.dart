import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_app/admin/admin_gate.dart';
import 'package:movies_app/core/services/service_locator.dart';
import 'package:movies_app/core/services/auth_service.dart';

class FakeAuthService extends AuthService {
  @override
  // Return a fake user by overriding currentUser getter
  // But AuthService.currentUser is not virtual; instead we override via composition by creating a shim
  // For the purposes of this test, we will create a minimal widget that registers a fake AuthService-like object
  // and AdminGate will fallback to FirebaseAuth instance; to avoid that, we circumvent by testing the unauthorized UI in debug mode
  get currentUser => null;
}

void main() {
  testWidgets('AdminGate shows dev sign-in in debug mode when no user', (WidgetTester tester) async {
    // Ensure service locator can be used in test
    sl.registerLazySingleton<AuthService>(() => FakeAuthService());

    await tester.pumpWidget(MaterialApp(home: AdminGate(child: const Text('ADMIN'))));

    // In tests, kDebugMode is true, so we expect the dev sign-in UI
    expect(find.text('Admin Sign-In (Dev)'), findsOneWidget);
    expect(find.text('Developer admin credentials (dev only)'), findsOneWidget);
  });
}

