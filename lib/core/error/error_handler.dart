import 'package:flutter_concepts/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

/// Wraps an asynchronous operation in a safe execution block.
///
/// Any exception thrown during execution is automatically caught
/// and mapped to a corresponding [AppFailure] using [AppFailure.fromException].
///
/// Returns [Right] with result on success, or [Left] with [AppFailure] on error.
Future<Either<AppFailure, T>> safeRepositoryCall<T>(
  Future<T> Function() action, {
  AppFailure Function(Object error, StackTrace stackTrace)? onError,
}) async {
  try {
    final result = await action();
    return Right(result);
  } catch (error, stackTrace) {
    if (onError != null) {
      return Left(onError(error, stackTrace));
    }
    return Left(AppFailure.fromException(error, stackTrace));
  }
}

/// Creates a [TaskEither] that safely executes [action], mapping
/// any thrown exceptions to an [AppFailure].
TaskEither<AppFailure, T> safeTask<T>(
  Future<T> Function() action, {
  AppFailure Function(Object error, StackTrace stackTrace)? onError,
}) {
  return TaskEither.tryCatch(
    action,
    onError ?? (error, stackTrace) => AppFailure.fromException(error, stackTrace),
  );
}
