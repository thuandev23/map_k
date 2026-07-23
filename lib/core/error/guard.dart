import 'exceptions.dart';
import 'failures.dart';
import 'result.dart';

/// Centralized Exception -> Failure converter to prevent duplicate try/catch code across Repositories.
Future<Either<Failure, T>> guard<T>(Future<T> Function() action) async {
  try {
    return Right(await action());
  } on ServerException catch (e) {
    return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
  } on CacheException catch (e) {
    return Left(CacheFailure(message: e.message));
  } on LocationPermissionException catch (e) {
    return Left(LocationPermissionFailure(message: e.message));
  } on LocationServiceDisabledException catch (e) {
    return Left(LocationServiceDisabledFailure(message: e.message));
  } catch (e) {
    return Left(UnknownFailure(message: e.toString()));
  }
}
