import 'package:flutter_concepts/core/common/entities/user.dart';
import 'package:flutter_concepts/core/error/failures.dart';
import 'package:flutter_concepts/core/usecase/base_usecase.dart';
import 'package:flutter_concepts/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class LoginUsecase implements BaseUseCase<User, LoginParams> {
final IAuthRepository authRepository;
  LoginUsecase({required this.authRepository});

  @override
  Future<Either<AppFailure, User>> call(LoginParams params) async {
    return await authRepository.logInWithEmailAndPassword(
      params.email,
      params.password,
    );
  }

}

class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
}