import 'package:flutter_concepts/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class BaseUseCase<S, P> {
  Future<Either<AppFailure, S>> call(P params);
}

class NoParams();
