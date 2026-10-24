import 'package:flutter_concepts/core/error/error_handler.dart';
import 'package:flutter_concepts/core/error/exceptions.dart';
import 'package:flutter_concepts/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppFailure.fromException', () {
    test('maps ServerException to ServerFailure', () {
      const exception = ServerException(message: 'Server error');
      final failure = AppFailure.fromException(exception);

      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'Server error');
    });

    test('maps CacheException to CacheFailure', () {
      const exception = CacheException(message: 'Cache error');
      final failure = AppFailure.fromException(exception);

      expect(failure, isA<CacheFailure>());
      expect(failure.message, 'Cache error');
    });

    test('maps NetworkException to NetworkFailure', () {
      const exception = NetworkException(message: 'Network error');
      final failure = AppFailure.fromException(exception);

      expect(failure, isA<NetworkFailure>());
      expect(failure.message, 'Network error');
    });

    test('returns AppFailure as is if already an AppFailure', () {
      const existingFailure = ServerFailure(message: 'Existing failure');
      final failure = AppFailure.fromException(existingFailure);

      expect(failure, equals(existingFailure));
    });

    test('maps unknown exception to UnexpectedFailure', () {
      final exception = FormatException('Bad format');
      final failure = AppFailure.fromException(exception);

      expect(failure, isA<UnexpectedFailure>());
      expect(failure.message, contains('Bad format'));
    });
  });

  group('safeRepositoryCall', () {
    test('returns Right when action succeeds', () async {
      final result = await safeRepositoryCall(() async => 'success');

      result.fold(
        (failure) => fail('Should have succeeded'),
        (data) => expect(data, 'success'),
      );
    });

    test('returns Left(ServerFailure) when ServerException is thrown', () async {
      final result = await safeRepositoryCall<String>(() async {
        throw const ServerException(message: 'Server failed');
      });

      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Server failed');
        },
        (data) => fail('Should have failed'),
      );
    });

    test('returns Left(CacheFailure) when CacheException is thrown', () async {
      final result = await safeRepositoryCall<String>(() async {
        throw const CacheException(message: 'Cache failed');
      });

      result.fold(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, 'Cache failed');
        },
        (data) => fail('Should have failed'),
      );
    });

    test('supports custom onError mapper', () async {
      final result = await safeRepositoryCall<String>(
        () async => throw Exception('custom'),
        onError: (e, st) => const ServerFailure(message: 'custom mapped'),
      );

      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'custom mapped');
        },
        (data) => fail('Should have failed'),
      );
    });
  });
}
