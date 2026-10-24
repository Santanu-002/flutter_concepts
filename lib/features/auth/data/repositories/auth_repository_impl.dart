import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_concepts/core/common/entities/user.dart';
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
  ) async {
    try {
      final userModel = await remoteDataSource.logInWithEmailAndPassword(
        email,
        password,
      );
      await localDataSource.saveUser(userModel);
      return right(userModel.toEntity());
    } catch (e) {
      return left(AppFailure.fromException(e));
    }
  }

  @override
  Future<Either<AppFailure, User>> signUpWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      final userModel = await remoteDataSource.signUpWithEmailAndPassword(
        name,
        email,
        password,
      );
      await localDataSource.saveUser(userModel);
      return right(userModel.toEntity());
    } catch (e) {
      return left(AppFailure.fromException(e));
    }
  }

  @override
  Future<Either<AppFailure, User?>> getCurrentUser() async {
    try {
      final userModel = await localDataSource.getCurrentUser();
      if (userModel != null) {
        return right(userModel.toEntity());
      } else {
        return left(
          const CacheFailure(message: 'No user is currently logged in'),
        );
      }
    } catch (e) {
      return left(AppFailure.fromException(e));
    }
  }

  @override
  Future<Either<AppFailure, bool>> isLoggedIn() async {
    try {
      final loggedIn = await localDataSource.isLoggedIn();
      return right(loggedIn);
    } catch (e) {
      return left(AppFailure.fromException(e));
    }
  }

  @override
  Future<Either<AppFailure, Unit>> signOut() async {
    try {
      unawaited(
        remoteDataSource.signOut().catchError(
          (_) => debugPrint('Failed to sign out from remote'),
        ),
      );

      await localDataSource.clearUser();
      return right(unit);
    } catch (e) {
      return left(AppFailure.fromException(e));
    }
  }
}
