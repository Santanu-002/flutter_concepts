import 'package:flutter_concepts/core/error/exceptions.dart';

sealed class AppFailure {
  final String message;

  const AppFailure({required this.message});

  @override
  String toString() => '$runtimeType: $message';

  factory AppFailure.fromException(Object error) {
    return switch (error) {
      ServerException(:final message) => ServerFailure(message: message),
      CacheException(:final message) => CacheFailure(message: message),
      NetworkException(:final message) => NetworkFailure(message: message),
      AppFailure failure => failure,
      _ => UnexpectedFailure(
          message: error is Exception
              ? error.toString()
              : 'An unexpected error occurred: $error',
        ),
    };
  }
}

class ServerFailure extends AppFailure {
  const ServerFailure({required super.message});
}

class CacheFailure extends AppFailure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends AppFailure {
  const NetworkFailure({required super.message});
}

class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure({super.message = 'An unexpected error occurred'});
}
