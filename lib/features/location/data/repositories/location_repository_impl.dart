import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
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
  Future<Either<Failure, LocationEntity>> getCurrentLocation() {
    return guard(() async {
      return await local.getCurrentLocation();
    });
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
