import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class FirebaseAuthDataSource {
  FirebaseAuthDataSource({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _auth = firebaseAuth,
        _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<UserModel?> get authStateChanges => _auth.authStateChanges().map(
        (user) => user != null ? UserModel.fromFirebaseUser(user) : null,
      );

  UserModel? get currentUser {
    final user = _auth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  Future<UserModel> signInWithEmailPassword(
      String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return UserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  Future<UserModel> signUpWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.reload();

      final user = UserModel.fromFirebaseUser(_auth.currentUser!);

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(user.toMap());

      return UserModel(
        uid: user.uid,
        email: user.email,
        displayName: displayName,
        photoUrl: user.photoUrl,
        phoneNumber: user.phoneNumber,
        createdAt: user.createdAt,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  Exception _mapException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No account found with this email.');
      case 'wrong-password':
        return Exception('Incorrect password.');
      case 'email-already-in-use':
        return Exception('An account already exists with this email.');
      case 'invalid-email':
        return Exception('The email address is not valid.');
      case 'weak-password':
        return Exception('Password is too weak.');
      case 'network-request-failed':
        return Exception('Network error. Check your connection.');
      default:
        return Exception(e.message ?? 'Authentication failed.');
    }
  }
}