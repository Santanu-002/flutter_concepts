import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_concepts/core/common/entities/user.dart';
import 'package:flutter_concepts/core/error/error_handler.dart';
import 'package:flutter_concepts/core/error/exceptions.dart';
import 'package:flutter_concepts/core/error/failures.dart';
import 'package:flutter_concepts/features/auth/data/datasources/local/i_auth_local_datasource.dart';
import 'package:flutter_concepts/features/auth/data/datasources/remote/i_auth_remote_datasource.dart';
import 'package:flutter_concepts/features/auth/data/models/user_model.dart';
import 'package:flutter_concepts/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource remoteDataSource;
  final IAuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<AppFailure, User>> logInWithEmailAndPassword(
    String email,
    String password,
  ) => safeRepositoryCall(() async {
    final userModel = await remoteDataSource.logInWithEmailAndPassword(
      email,
      password,
    );
    await localDataSource.saveUser(userModel);
    return userModel.toEntity();
  });

  @override
  Future<Either<AppFailure, User>> signUpWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) => safeRepositoryCall(() async {
    final userModel = await remoteDataSource.signUpWithEmailAndPassword(
      name,
      email,
      password,
    );
    await localDataSource.saveUser(userModel);
    return userModel.toEntity();
  });

  @override
  Future<Either<AppFailure, User?>> getCurrentUser() => safeRepositoryCall(() async {
    final userModel = await localDataSource.getCurrentUser();
    if (userModel == null) {
      throw const CacheException(message: 'No user is currently logged in');
    }
    return userModel.toEntity();
  });

  @override
  Future<Either<AppFailure, bool>> isLoggedIn() => safeRepositoryCall(
    () => localDataSource.isLoggedIn(),
  );

  @override
  Future<Either<AppFailure, Unit>> signOut() => safeRepositoryCall(() async {
    try {
      await localDataSource.clearUser();
      return unit;
    } finally {
      try {
        await remoteDataSource.signOut();
      } catch (e) {
        debugPrint('Failed to sign out from remote: $e');
      }
    }
  });
}
