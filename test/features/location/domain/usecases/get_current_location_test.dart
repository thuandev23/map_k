import 'package:flutter_test/flutter_test.dart';
import 'package:map_k/core/error/failures.dart';
import 'package:map_k/core/error/result.dart';
import 'package:map_k/core/usecase/usecase.dart';
import 'package:map_k/features/location/domain/entities/location_entity.dart';
import 'package:map_k/features/location/domain/repositories/location_repository.dart';
import 'package:map_k/features/location/domain/usecases/get_current_location.dart';

class MockLocationRepository implements LocationRepository {
  final Either<Failure, LocationEntity> mockResult;

  MockLocationRepository(this.mockResult);

  @override
  Future<Either<Failure, LocationEntity>> getCurrentLocation() async {
    return mockResult;
  }

  @override
  Stream<Either<Failure, LocationEntity>> watchLocationStream() async* {
    yield mockResult;
  }
}

void main() {
  group('GetCurrentLocation UseCase Test', () {
    final tLocation = LocationEntity(
      latitude: 10.776889,
      longitude: 106.700806,
      accuracy: 5.0,
      timestamp: DateTime.parse('2026-07-23T10:00:00Z'),
    );

    test('should return LocationEntity from repository when call is successful', () async {
      final repository = MockLocationRepository(Right(tLocation));
      final useCase = GetCurrentLocation(repository);

      final result = await useCase(const NoParams());

      expect(result.isRight, true);
      expect(result.rightOrNull, tLocation);
    });

    test('should return LocationPermissionFailure when permission denied', () async {
      const failure = LocationPermissionFailure(message: 'Permission denied');
      final repository = MockLocationRepository(const Left(failure));
      final useCase = GetCurrentLocation(repository);

      final result = await useCase(const NoParams());

      expect(result.isLeft, true);
      expect(result.leftOrNull, failure);
    });
  });
}
