import 'package:flutter_concepts/features/auth/data/models/user_model.dart';

abstract interface class IAuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<void> clearUser();
}
