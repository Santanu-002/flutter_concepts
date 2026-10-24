import 'package:flutter_concepts/core/error/exceptions.dart';
import 'package:flutter_concepts/features/auth/data/datasources/local/i_auth_local_datasource.dart';
import 'package:flutter_concepts/features/auth/data/models/user_model.dart';

class AuthLocalDatasourceImpl implements IAuthLocalDataSource {
  Future<T> _perform<T>(
    Future<T> Function() action, {
    required String errorMessage,
  }) async {
    try {
      return await action();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(message: errorMessage);
    }
  }

  @override
  Future<void> saveUser(UserModel user) => _perform(
    () => Future.delayed(const Duration(seconds: 1)),
    errorMessage: 'Failed to save user',
  );

  @override
  Future<UserModel?> getCurrentUser() => _perform(
    () => Future.delayed(
      const Duration(seconds: 1),
      () => UserModel(
        uid: '123',
        name: 'John Doe',
        email: 'john.doe@example.com',
      ),
    ),
    errorMessage: 'Failed to get current user',
  );

  @override
  Future<bool> isLoggedIn() => _perform(
    () => Future.delayed(const Duration(seconds: 1), () => true),
    errorMessage: 'Failed to check login status',
  );

  @override
  Future<void> clearUser() => _perform(
    () => Future.delayed(const Duration(seconds: 1)),
    errorMessage: 'Failed to clear user data',
  );
}
