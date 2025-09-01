// lib/core/auth/google_auth_real.dart
// Реальная реализация для Android/других платформ
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_service_interface.dart';

class GoogleAuthService implements AuthServiceInterface {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  @override
  Future<bool> get isAvailable async => true;

  @override
  Future<Map<String, dynamic>?> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        final GoogleSignInAuthentication auth = await account.authentication;
        return {
          'accessToken': auth.accessToken,
          'idToken': auth.idToken,
          'email': account.email,
          'displayName': account.displayName,
          'photoUrl': account.photoUrl,
        };
      }
    } catch (e) {
      print('Google Sign-In error: $e');
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  @override
  Future<bool> isSignedIn() async {
    return _googleSignIn.currentUser != null;
  }
}