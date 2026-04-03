import 'package:finxl/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  /// Stream of user auth state changes. Null means unauthenticated.
  Stream<UserEntity?> get authStateChanges;

  /// Gets the currently signed-in user, if any.
  UserEntity? get currentUser;

  /// Sign in with email and password.
  Future<UserEntity?> signInWithEmail(String email, String password);

  /// Sign in with Google.
  Future<UserEntity?> signInWithGoogle();

  /// Sign up with email, password and full name.
  Future<UserEntity?> signUpWithEmail(
    String email,
    String password, {
    String? fullName,
  });

  /// Reset password.
  Future<void> sendPasswordReset(String email);

  /// Sign out.
  Future<void> signOut();
}
