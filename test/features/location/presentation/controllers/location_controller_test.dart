import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:map_k/core/error/failures.dart';
import 'package:map_k/core/error/result.dart';
import 'package:map_k/core/usecase/usecase.dart';
import 'package:map_k/features/location/domain/entities/location_entity.dart';
import 'package:map_k/features/location/domain/usecases/get_current_location.dart';
import 'package:map_k/features/location/domain/usecases/watch_location_stream.dart';
import 'package:map_k/features/location/presentation/controllers/location_controller.dart';

class MockGetCurrentLocation extends Mock implements GetCurrentLocation {}

class MockWatchLocationStream extends Mock implements WatchLocationStream {}

void main() {
  late MockGetCurrentLocation mockGetCurrentLocation;
  late MockWatchLocationStream mockWatchLocationStream;

  final tLocation = LocationEntity(
    latitude: 10.776889,
    longitude: 106.700806,
    accuracy: 5.0,
    timestamp: DateTime.parse('2026-07-23T10:00:00Z'),
  );

  setUp(() {
    mockGetCurrentLocation = MockGetCurrentLocation();
    mockWatchLocationStream = MockWatchLocationStream();

    when(() => mockWatchLocationStream(const NoParams()))
        .thenAnswer((_) => Stream.value(Right(tLocation)));
  });

  group('LocationController Unit Tests with Mocktail', () {
    test('initial state should settle to AsyncData when GetCurrentLocation succeeds', () async {
      when(() => mockGetCurrentLocation(const NoParams()))
          .thenAnswer((_) async => Right(tLocation));

      final controller = LocationController(
        mockGetCurrentLocation,
        mockWatchLocationStream,
      );

      await Future.delayed(Duration.zero);
      expect(controller.state, AsyncData<LocationEntity>(tLocation));
    });

    test('state should be AsyncData when GetCurrentLocation succeeds', () async {
      when(() => mockGetCurrentLocation(const NoParams()))
          .thenAnswer((_) async => Right(tLocation));

      final controller = LocationController(
        mockGetCurrentLocation,
        mockWatchLocationStream,
      );

      await controller.init();

      expect(controller.state.value, tLocation);
      expect(controller.state.hasValue, true);
    });

    test('state should be AsyncError when GetCurrentLocation fails', () async {
      const failure = LocationPermissionFailure(message: 'Permission Denied');
      when(() => mockGetCurrentLocation(const NoParams()))
          .thenAnswer((_) async => const Left(failure));

      final controller = LocationController(
        mockGetCurrentLocation,
        mockWatchLocationStream,
      );

      await controller.refreshLocation();

      expect(controller.state.hasError, true);
      expect(controller.state.error, 'Permission Denied');
    });
  });
}
