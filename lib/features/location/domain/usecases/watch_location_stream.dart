import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/location_entity.dart';
import '../repositories/location_repository.dart';

/// StreamUseCase to listen to continuous location stream updates.
/// Pure Dart - NO package:flutter imports.
class WatchLocationStream implements StreamUseCase<LocationEntity, NoParams> {
  final LocationRepository repository;

  WatchLocationStream(this.repository);

  @override
  Stream<Either<Failure, LocationEntity>> call(NoParams params) {
    return repository.watchLocationStream();
  }
}
