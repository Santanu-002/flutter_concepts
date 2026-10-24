import 'package:flutter_concepts/core/error/exceptions.dart';
import 'package:flutter_concepts/features/auth/data/datasources/remote/i_auth_remote_datasource.dart';
import 'package:flutter_concepts/features/auth/data/models/user_model.dart';

class AuthRemoteDatasourceImpl implements IAuthRemoteDataSource {
  @override
  Future<UserModel> logInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await Future.delayed(
        const Duration(seconds: 2),
      ); // network call simulation
      return UserModel(uid: '123', name: 'John Doe', email: email);
    } catch (e) {
      throw const ServerException(message: 'Failed to log in');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      return UserModel(uid: '456', name: name, email: email);
    } catch (e) {
      throw const ServerException(message: 'Failed to sign up');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      throw const ServerException(message: 'Failed to sign out');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return const UserModel(
        uid: '123',
        name: 'John Doe',
        email: 'john.doe@example.com',
      );
    } catch (e) {
      throw const ServerException(message: 'Failed to get current user');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return true; // Simulating that the user is logged in
    } catch (e) {
      throw const ServerException(message: 'Failed to check login status');
    }
  }
}
