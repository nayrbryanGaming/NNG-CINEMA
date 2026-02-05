import 'package:flutter/foundation.dart';
import 'package:movies_app/core/services/auth_service.dart';

class AuthStateNotifier extends ChangeNotifier {
  final AuthService _auth;

  AuthStateNotifier(this._auth) {
    // listen to auth changes and notify listeners to refresh router redirects
    _auth.authStateChanges().listen((_) {
      notifyListeners();
    });
  }
}

