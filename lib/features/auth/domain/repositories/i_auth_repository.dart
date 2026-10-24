import 'package:flutter_concepts/core/common/entities/user.dart';
import 'package:flutter_concepts/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class IAuthRepository {
  Future<Either<AppFailure, User>> logInWithEmailAndPassword(String email, String password);
  Future<Either<AppFailure, User>> signUpWithEmailAndPassword(String name, String email, String password);
  Future<Either<AppFailure, Unit>> signOut();
  Future<Either<AppFailure, User?>> getCurrentUser();
  Future<Either<AppFailure, bool>> isLoggedIn();
}