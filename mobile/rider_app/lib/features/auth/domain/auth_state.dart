import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState { const AuthInitial(); }
class AuthLoading extends AuthState { const AuthLoading(); }

class AuthAuthenticated extends AuthState {
  final RiderUser user;
  const AuthAuthenticated({required this.user});
  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState { const AuthUnauthenticated(); }

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
  @override
  List<Object> get props => [message];
}

class RiderUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final bool isAvailable;
  final double rating;

  const RiderUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.isAvailable = false,
    this.rating = 0.0,
  });

  factory RiderUser.fromJson(Map<String, dynamic> json) => RiderUser(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        isAvailable: json['is_available'] as bool? ?? false,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      );

  @override
  List<Object?> get props => [id, name, email, isAvailable, rating];
}
