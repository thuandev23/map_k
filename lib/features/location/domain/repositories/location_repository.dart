import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/location_entity.dart';

/// Pure Dart LocationRepository Contract.
/// NO package:flutter imports allowed here.
abstract class LocationRepository {
  Future<Either<Failure, LocationEntity>> getCurrentLocation();
  Stream<Either<Failure, LocationEntity>> watchLocationStream();
}
