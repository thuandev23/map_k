import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_local_data_source.dart';
import '../datasources/location_remote_data_source.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationLocalDataSource local;
  final LocationRemoteDataSource remote;

  LocationRepositoryImpl({
    required this.local,
    required this.remote,
  });

  @override
  Future<Either<Failure, LocationEntity>> getCurrentLocation() async {
    try {
      final model = await local.getCurrentLocation();
      return Right(model);
    } on LocationPermissionException catch (e) {
      return Left(LocationPermissionFailure(message: e.message));
    } on LocationServiceDisabledException catch (e) {
      return Left(LocationServiceDisabledFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, LocationEntity>> watchLocationStream() async* {
    try {
      await for (final model in local.watchLocationStream()) {
        yield Right(model);
      }
    } catch (e) {
      yield Left(UnknownFailure(message: e.toString()));
    }
  }
}
