import 'package:flutter_concepts/features/auth/data/models/user_model.dart';

abstract interface class IAuthRemoteDataSource {
  Future<UserModel> logInWithEmailAndPassword(String email, String password);
  Future<UserModel> signUpWithEmailAndPassword(String name, String email, String password);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<bool> isLoggedIn();
}