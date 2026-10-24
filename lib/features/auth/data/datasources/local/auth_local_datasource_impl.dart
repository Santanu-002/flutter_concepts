import 'package:flutter_concepts/core/error/exceptions.dart';
import 'package:flutter_concepts/features/auth/data/datasources/local/i_auth_local_datasource.dart';
import 'package:flutter_concepts/features/auth/data/models/user_model.dart';

class AuthLocalDatasourceImpl implements IAuthLocalDataSource {
  @override
  Future<void> saveUser(UserModel user) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      throw const CacheException(message: 'Failed to save user');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      return await Future.delayed(
        const Duration(seconds: 1),
        () => const UserModel(
          uid: '123',
          name: 'John Doe',
          email: 'john.doe@example.com',
        ),
      );
    } catch (e) {
      throw const CacheException(message: 'Failed to get current user');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return await Future.delayed(const Duration(seconds: 1), () => true);
    } catch (e) {
      throw const CacheException(message: 'Failed to check login status');
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      throw const CacheException(message: 'Failed to clear user data');
    }
  }
}
