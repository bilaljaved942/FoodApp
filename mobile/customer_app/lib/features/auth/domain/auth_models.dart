import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'auth_models.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// User
// ─────────────────────────────────────────────────────────────────────────────

@JsonSerializable(fieldRename: FieldRename.snake)
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String role;
  final bool isVerified;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.role = 'customer',
    this.isVerified = false,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? role,
    bool? isVerified,
    DateTime? createdAt,
  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        role: role ?? this.role,
        isVerified: isVerified ?? this.isVerified,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [id, name, email, phone, avatarUrl, role, isVerified];
}

// ─────────────────────────────────────────────────────────────────────────────
// Login Request
// ─────────────────────────────────────────────────────────────────────────────

@JsonSerializable(fieldRename: FieldRename.snake)
class LoginRequest extends Equatable {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);

  @override
  List<Object> get props => [email, password];
}

// ─────────────────────────────────────────────────────────────────────────────
// Register Request
// ─────────────────────────────────────────────────────────────────────────────

@JsonSerializable(fieldRename: FieldRename.snake)
class RegisterRequest extends Equatable {
  final String name;
  final String email;
  final String password;
  final String? phone;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);

  @override
  List<Object?> get props => [name, email, password, phone];
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth Response (login / register)
// ─────────────────────────────────────────────────────────────────────────────

@JsonSerializable(fieldRename: FieldRename.snake)
class AuthResponse extends Equatable {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final User user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  @override
  List<Object> get props => [accessToken, refreshToken, expiresIn, user];
}

// ─────────────────────────────────────────────────────────────────────────────
// Refresh Token Request
// ─────────────────────────────────────────────────────────────────────────────

@JsonSerializable(fieldRename: FieldRename.snake)
class RefreshTokenRequest {
  final String refreshToken;

  const RefreshTokenRequest({required this.refreshToken});

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Forgot Password Request
// ─────────────────────────────────────────────────────────────────────────────

@JsonSerializable(fieldRename: FieldRename.snake)
class ForgotPasswordRequest {
  final String email;

  const ForgotPasswordRequest({required this.email});

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ForgotPasswordRequestToJson(this);
}
