import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:finxl/features/auth/domain/entities/user_entity.dart';
import 'package:finxl/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthInitial()) {
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<UserEntity?> _authSubscription;

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authRepository.signInWithEmail(email, password);
      // Real authentication state is handled by the auth state listener.
    } catch (error) {
      emit(AuthError(message: _messageFromError(error)));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      await _authRepository.signInWithGoogle();
      // Real authentication state is handled by the auth state listener.
    } catch (error) {
      emit(AuthError(message: _messageFromError(error)));
    }
  }

  Future<void> signUp(String email, String password, String fullName) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUpWithEmail(
        email,
        password,
        fullName: fullName,
      );
    } catch (error) {
      emit(AuthError(message: _messageFromError(error)));
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authRepository.sendPasswordReset(email);
    } catch (error) {
      emit(AuthError(message: _messageFromError(error)));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
    } catch (error) {
      emit(AuthError(message: _messageFromError(error)));
    }
  }

  String _messageFromError(Object error) {
    final message = error.toString();
    return message.replaceFirst('Exception: ', '');
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
