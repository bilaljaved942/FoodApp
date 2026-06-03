import 'package:equatable/equatable.dart';

import 'auth_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Auth State  (sealed-class style via abstract + subclasses)
// ─────────────────────────────────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any auth check has been performed.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Auth check / login / register is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// A valid session exists.
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

/// No valid session (logged out or never signed in).
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Login / register succeeded but the account still needs email/phone verification.
class AuthNeedsVerification extends AuthState {
  final String email;

  const AuthNeedsVerification({required this.email});

  @override
  List<Object> get props => [email];
}

/// A password reset email has been sent successfully.
class AuthPasswordResetSent extends AuthState {
  final String email;

  const AuthPasswordResetSent({required this.email});

  @override
  List<Object> get props => [email];
}

/// An auth operation failed.
class AuthError extends AuthState {
  final String message;
  final int? statusCode;

  const AuthError({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}
