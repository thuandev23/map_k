import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/location_entity.dart';
import '../repositories/location_repository.dart';

/// UseCase to fetch current user location.
/// Pure Dart - NO package:flutter imports.
class GetCurrentLocation implements UseCase<LocationEntity, NoParams> {
  final LocationRepository repository;

  GetCurrentLocation(this.repository);

  @override
  Future<Either<Failure, LocationEntity>> call(NoParams params) async {
    return await repository.getCurrentLocation();
  }
}
