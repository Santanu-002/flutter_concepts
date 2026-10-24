import 'package:flutter_concepts/core/error/exceptions.dart';
import 'package:flutter_concepts/core/error/failures.dart';
import 'package:flutter_concepts/features/auth/data/datasources/local/i_auth_local_datasource.dart';
import 'package:flutter_concepts/features/auth/data/datasources/remote/i_auth_remote_datasource.dart';
import 'package:flutter_concepts/features/auth/data/models/user_model.dart';
import 'package:flutter_concepts/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class FakeAuthRemoteDataSource implements IAuthRemoteDataSource {
  UserModel Function(String email, String password)? onLogIn;
  UserModel Function(String name, String email, String password)? onSignUp;
  Future<void> Function()? onSignOut;
  UserModel? Function()? onGetCurrentUser;
  bool Function()? onIsLoggedIn;

  @override
  Future<UserModel> logInWithEmailAndPassword(String email, String password) async {
    return onLogIn != null
        ? onLogIn!(email, password)
        : UserModel(uid: '1', name: 'User', email: email);
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    return onSignUp != null
        ? onSignUp!(name, email, password)
        : UserModel(uid: '1', name: name, email: email);
  }

  @override
  Future<void> signOut() async {
    if (onSignOut != null) await onSignOut!();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return onGetCurrentUser != null ? onGetCurrentUser!() : null;
  }

  @override
  Future<bool> isLoggedIn() async {
    return onIsLoggedIn != null ? onIsLoggedIn!() : true;
  }
}

class FakeAuthLocalDataSource implements IAuthLocalDataSource {
  UserModel? savedUser;
  bool clearCalled = false;
  Future<void> Function(UserModel user)? onSaveUser;
  UserModel? Function()? onGetCurrentUser;
  bool Function()? onIsLoggedIn;
  Future<void> Function()? onClearUser;

  @override
  Future<void> saveUser(UserModel user) async {
    if (onSaveUser != null) {
      await onSaveUser!(user);
    } else {
      savedUser = user;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return onGetCurrentUser != null ? onGetCurrentUser!() : savedUser;
  }

  @override
  Future<bool> isLoggedIn() async {
    return onIsLoggedIn != null ? onIsLoggedIn!() : savedUser != null;
  }

  @override
  Future<void> clearUser() async {
    if (onClearUser != null) {
      await onClearUser!();
    } else {
      clearCalled = true;
      savedUser = null;
    }
  }
}

void main() {
  late FakeAuthRemoteDataSource remoteDataSource;
  late FakeAuthLocalDataSource localDataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    remoteDataSource = FakeAuthRemoteDataSource();
    localDataSource = FakeAuthLocalDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );
  });

  group('logInWithEmailAndPassword', () {
    const email = 'test@example.com';
    const password = 'password123';

    test('returns User and saves to localDataSource on success', () async {
      final result = await repository.logInWithEmailAndPassword(email, password);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should not fail'),
        (user) {
          expect(user.email, email);
          expect(localDataSource.savedUser?.email, email);
        },
      );
    });

    test('returns ServerFailure when remoteDataSource throws ServerException', () async {
      remoteDataSource.onLogIn = (e, p) {
        throw const ServerException(message: 'Invalid credentials');
      };

      final result = await repository.logInWithEmailAndPassword(email, password);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Invalid credentials');
        },
        (_) => fail('Should not succeed'),
      );
    });

    test('returns CacheFailure when localDataSource.saveUser throws CacheException', () async {
      localDataSource.onSaveUser = (user) async {
        throw const CacheException(message: 'Disk full');
      };

      final result = await repository.logInWithEmailAndPassword(email, password);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, 'Disk full');
        },
        (_) => fail('Should not succeed'),
      );
    });
  });

  group('signUpWithEmailAndPassword', () {
    const name = 'New User';
    const email = 'new@example.com';
    const password = 'password123';

    test('returns User and saves to localDataSource on success', () async {
      final result = await repository.signUpWithEmailAndPassword(name, email, password);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should not fail'),
        (user) {
          expect(user.name, name);
          expect(user.email, email);
          expect(localDataSource.savedUser?.name, name);
        },
      );
    });

    test('returns ServerFailure when remoteDataSource throws ServerException', () async {
      remoteDataSource.onSignUp = (n, e, p) {
        throw const ServerException(message: 'Email already exists');
      };

      final result = await repository.signUpWithEmailAndPassword(name, email, password);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Email already exists');
        },
        (_) => fail('Should not succeed'),
      );
    });
  });

  group('getCurrentUser', () {
    test('returns User when user is found in cache', () async {
      localDataSource.savedUser = const UserModel(
        uid: '123',
        name: 'Cached User',
        email: 'cached@example.com',
      );

      final result = await repository.getCurrentUser();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should not fail'),
        (user) {
          expect(user?.name, 'Cached User');
        },
      );
    });

    test('returns CacheFailure when no user is currently logged in', () async {
      localDataSource.savedUser = null;

      final result = await repository.getCurrentUser();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, 'No user is currently logged in');
        },
        (_) => fail('Should not succeed'),
      );
    });

    test('returns CacheFailure when localDataSource throws CacheException', () async {
      localDataSource.onGetCurrentUser = () {
        throw const CacheException(message: 'Corrupted storage');
      };

      final result = await repository.getCurrentUser();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, 'Corrupted storage');
        },
        (_) => fail('Should not succeed'),
      );
    });
  });

  group('isLoggedIn', () {
    test('returns true when user is logged in', () async {
      localDataSource.savedUser = const UserModel(
        uid: '1',
        name: 'User',
        email: 'u@example.com',
      );

      final result = await repository.isLoggedIn();

      expect(result, const Right(true));
    });

    test('returns CacheFailure when localDataSource throws CacheException', () async {
      localDataSource.onIsLoggedIn = () {
        throw const CacheException(message: 'DB read error');
      };

      final result = await repository.isLoggedIn();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Should not succeed'),
      );
    });
  });

  group('signOut', () {
    test('clears local user even if remote signOut fails', () async {
      remoteDataSource.onSignOut = () async {
        throw const ServerException(message: 'Network offline');
      };

      final result = await repository.signOut();

      expect(result, const Right(unit));
      expect(localDataSource.clearCalled, isTrue);
    });

    test('returns CacheFailure when local clearUser throws CacheException', () async {
      localDataSource.onClearUser = () async {
        throw const CacheException(message: 'Failed to clear disk');
      };

      final result = await repository.signOut();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, 'Failed to clear disk');
        },
        (_) => fail('Should not succeed'),
      );
    });
  });
}
