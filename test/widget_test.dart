import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:map_k/core/error/result.dart';
import 'package:map_k/core/usecase/usecase.dart';
import 'package:map_k/features/location/domain/entities/location_entity.dart';
import 'package:map_k/features/location/domain/usecases/get_current_location.dart';
import 'package:map_k/features/location/domain/usecases/watch_location_stream.dart';
import 'package:map_k/features/location/presentation/controllers/location_controller.dart';
import 'package:map_k/main.dart';

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

    when(() => mockGetCurrentLocation(const NoParams()))
        .thenAnswer((_) async => Right(tLocation));
    when(() => mockWatchLocationStream(const NoParams()))
        .thenAnswer((_) => Stream.value(Right(tLocation)));
  });

  testWidgets('MapKApp renders MapScreen title', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          locationControllerProvider.overrideWith(
            (ref) => LocationController(
              mockGetCurrentLocation,
              mockWatchLocationStream,
            ),
          ),
        ],
        child: const MapKApp(),
      ),
    );

    await tester.pump();

    expect(find.text('Map K — MapLibre & GPS Channel'), findsOneWidget);
  });
}
