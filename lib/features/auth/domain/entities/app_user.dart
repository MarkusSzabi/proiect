import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.createdAt,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final DateTime? createdAt;

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [uid, email, displayName, photoUrl, phoneNumber];
}