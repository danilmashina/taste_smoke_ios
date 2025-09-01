// lib/core/auth/auth_service_interface.dart
abstract class AuthServiceInterface {
  Future<bool> get isAvailable;
  Future<Map<String, dynamic>?> signIn();
  Future<void> signOut();
  Future<bool> isSignedIn();
}