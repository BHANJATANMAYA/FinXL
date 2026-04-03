import 'package:finxl/features/auth/domain/entities/user_entity.dart';
import 'package:finxl/features/auth/domain/repositories/auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepositoryImpl implements AuthRepository {
  SupabaseAuthRepositoryImpl(
    this._client, {
    String? googleWebClientId,
    String? googleIosClientId,
    GoogleSignIn? googleSignIn,
  }) : _googleWebClientId = googleWebClientId,
       _googleIosClientId = googleIosClientId,
       _googleSignIn = googleSignIn;

  final SupabaseClient _client;
  final String? _googleWebClientId;
  final String? _googleIosClientId;
  GoogleSignIn? _googleSignIn;

  GoogleSignIn get _googleSignInClient {
    final webClientId = _googleWebClientId;
    if (webClientId == null || webClientId.trim().isEmpty) {
      throw Exception(
        'Missing GOOGLE_WEB_CLIENT_ID. Add the Google Web client ID to your .env file.',
      );
    }

    return _googleSignIn ??= GoogleSignIn(
      serverClientId: webClientId,
      clientId: _googleIosClientId,
    );
  }

  Future<T> _runAuthRequest<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on AuthException catch (error) {
      throw Exception(error.message);
    }
  }

  /// Converts a Supabase [User] to our domain [UserEntity].
  UserEntity? _toEntity(User? user) {
    if (user == null) return null;

    final metadata = user.userMetadata;
    return UserEntity(
      id: user.id,
      email: user.email,
      fullName:
          metadata?['full_name'] as String? ?? metadata?['name'] as String?,
    );
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((event) {
      return _toEntity(event.session?.user);
    });
  }

  @override
  UserEntity? get currentUser => _toEntity(_client.auth.currentUser);

  @override
  Future<UserEntity?> signInWithEmail(String email, String password) {
    return _runAuthRequest(() async {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return _toEntity(response.user);
    });
  }

  @override
  Future<UserEntity?> signInWithGoogle() {
    return _runAuthRequest(() async {
      final googleUser = await _googleSignInClient.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Google access token is missing.');
      }
      if (idToken == null || idToken.isEmpty) {
        throw Exception('Google ID token is missing.');
      }

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      return _toEntity(response.user);
    });
  }

  @override
  Future<UserEntity?> signUpWithEmail(
    String email,
    String password, {
    String? fullName,
  }) {
    return _runAuthRequest(() async {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );
      return _toEntity(response.user);
    });
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return _runAuthRequest(() async {
      await _client.auth.resetPasswordForEmail(email);
    });
  }

  @override
  Future<void> signOut() {
    return _runAuthRequest(() async {
      await _client.auth.signOut();
      await _googleSignIn?.signOut();
    });
  }
}
