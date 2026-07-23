import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:map_k/core/error/failures.dart';
import 'package:map_k/core/error/result.dart';
import 'package:map_k/core/usecase/usecase.dart';
import 'package:map_k/features/location/domain/entities/location_entity.dart';
import 'package:map_k/features/location/domain/repositories/location_repository.dart';
import 'package:map_k/features/location/domain/usecases/get_current_location.dart';

class MockLocationRepository extends Mock implements LocationRepository {}

void main() {
  late MockLocationRepository mockRepository;
  late GetCurrentLocation useCase;

  final tLocation = LocationEntity(
    latitude: 10.776889,
    longitude: 106.700806,
    accuracy: 5.0,
    timestamp: DateTime.parse('2026-07-23T10:00:00Z'),
  );

  setUp(() {
    mockRepository = MockLocationRepository();
    useCase = GetCurrentLocation(mockRepository);
  });

  group('GetCurrentLocation Unit Tests with Mocktail', () {
    test('GetCurrentLocation returns LocationEntity on success', () async {
      when(() => mockRepository.getCurrentLocation())
          .thenAnswer((_) async => Right(tLocation));

      final result = await useCase(const NoParams());

      expect(result, Right<Failure, LocationEntity>(tLocation));
      verify(() => mockRepository.getCurrentLocation()).called(1);
    });

    test('GetCurrentLocation returns LocationPermissionFailure on failure', () async {
      const failure = LocationPermissionFailure(message: 'Quyền vị trí bị từ chối');
      when(() => mockRepository.getCurrentLocation())
          .thenAnswer((_) async => const Left(failure));

      final result = await useCase(const NoParams());

      expect(result, const Left<Failure, LocationEntity>(failure));
      verify(() => mockRepository.getCurrentLocation()).called(1);
    });
  });
}
