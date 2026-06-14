import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../domain/entities/app_user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.uid,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.phoneNumber,
    super.createdAt,
  });

  factory UserModel.fromFirebaseUser(fb.User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      phoneNumber: user.phoneNumber,
      createdAt: user.metadata.creationTime,
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'phoneNumber': phoneNumber,
        'createdAt': createdAt?.toIso8601String(),
      };
}