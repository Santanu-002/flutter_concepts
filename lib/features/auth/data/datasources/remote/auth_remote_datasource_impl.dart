import 'package:flutter_concepts/core/error/exceptions.dart';
import 'package:flutter_concepts/features/auth/data/datasources/remote/i_auth_remote_datasource.dart';
import 'package:flutter_concepts/features/auth/data/models/user_model.dart';

class AuthRemoteDatasourceImpl implements IAuthRemoteDataSource {
  Future<T> _perform<T>(
    Future<T> Function() action, {
    required String errorMessage,
  }) async {
    try {
      return await action();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: errorMessage);
    }
  }

  @override
  Future<UserModel> logInWithEmailAndPassword(
    String email,
    String password,
  ) => _perform(
    () async {
      await Future.delayed(const Duration(seconds: 2)); // network call simulation
      return UserModel(uid: '123', name: 'John Doe', email: email);
    },
    errorMessage: 'Failed to log in',
  );

  @override
  Future<UserModel> signUpWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) => _perform(
    () async {
      await Future.delayed(const Duration(seconds: 2));
      return UserModel(uid: '456', name: name, email: email);
    },
    errorMessage: 'Failed to sign up',
  );

  @override
  Future<void> signOut() => _perform(
    () => Future.delayed(const Duration(seconds: 1)),
    errorMessage: 'Failed to sign out',
  );

  @override
  Future<UserModel?> getCurrentUser() => _perform(
    () async {
      await Future.delayed(const Duration(seconds: 1));
      return UserModel(
        uid: '123',
        name: 'John Doe',
        email: 'john.doe@example.com',
      );
    },
    errorMessage: 'Failed to get current user',
  );

  @override
  Future<bool> isLoggedIn() => _perform(
    () => Future.delayed(const Duration(seconds: 1), () => true),
    errorMessage: 'Failed to check login status',
  );
}
