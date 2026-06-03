import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../data/auth_repository.dart';
import '../domain/auth_models.dart';
import '../domain/auth_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Events
// ─────────────────────────────────────────────────────────────────────────────

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

/// Fired on app start to check if a valid session exists.
class AuthCheckStatusEvent extends AuthEvent {
  const AuthCheckStatusEvent();
}

/// Fired when the user submits the login form.
class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

/// Fired when the user submits the registration form.
class AuthRegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String? phone;

  const AuthRegisterEvent({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
  });

  @override
  List<Object?> get props => [name, email, password, phone];
}

/// Fired when the user taps "Forgot Password".
class AuthForgotPasswordEvent extends AuthEvent {
  final String email;

  const AuthForgotPasswordEvent({required this.email});

  @override
  List<Object> get props => [email];
}

/// Fired when the user logs out.
class AuthLogoutEvent extends AuthEvent {
  const AuthLogoutEvent();
}

// ─────────────────────────────────────────────────────────────────────────────
// BLoC
// ─────────────────────────────────────────────────────────────────────────────

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(const AuthInitial()) {
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<AuthLoginEvent>(_onLogin);
    on<AuthRegisterEvent>(_onRegister);
    on<AuthForgotPasswordEvent>(_onForgotPassword);
    on<AuthLogoutEvent>(_onLogout);
  }

  // ─── Check Status ─────────────────────────────────────────────────────────
  Future<void> _onCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  // ─── Login ────────────────────────────────────────────────────────────────
  Future<void> _onLogin(
    AuthLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response = await _repository.login(
        email: event.email,
        password: event.password,
      );
      if (!response.user.isVerified) {
        emit(AuthNeedsVerification(email: response.user.email));
      } else {
        emit(AuthAuthenticated(user: response.user));
      }
    } on Exception catch (e) {
      emit(AuthError(message: _parseError(e)));
    }
  }

  // ─── Register ─────────────────────────────────────────────────────────────
  Future<void> _onRegister(
    AuthRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response = await _repository.register(
        name: event.name,
        email: event.email,
        password: event.password,
        phone: event.phone,
      );
      emit(AuthNeedsVerification(email: response.user.email));
    } on Exception catch (e) {
      emit(AuthError(message: _parseError(e)));
    }
  }

  // ─── Forgot Password ──────────────────────────────────────────────────────
  Future<void> _onForgotPassword(
    AuthForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _repository.forgotPassword(event.email);
      emit(AuthPasswordResetSent(email: event.email));
    } on Exception catch (e) {
      emit(AuthError(message: _parseError(e)));
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  Future<void> _onLogout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.logout();
    emit(const AuthUnauthenticated());
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  String _parseError(Object error) {
    final msg = error.toString();
    if (msg.contains('401') || msg.toLowerCase().contains('invalid credentials')) {
      return 'Invalid email or password. Please try again.';
    }
    if (msg.contains('422') || msg.toLowerCase().contains('validation')) {
      return 'Please check your input and try again.';
    }
    if (msg.toLowerCase().contains('network') ||
        msg.toLowerCase().contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    return 'Something went wrong. Please try again.';
  }
}
