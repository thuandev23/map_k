import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:map_k/features/location/domain/entities/location_entity.dart';
import 'package:map_k/features/location/presentation/controllers/location_controller.dart';
import 'package:map_k/main.dart';

void main() {
  final tLocation = LocationEntity(
    latitude: 10.776889,
    longitude: 106.700806,
    accuracy: 5.0,
    timestamp: DateTime.parse('2026-07-23T10:00:00Z'),
  );

  testWidgets('MapKApp renders LocationScreen title', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override locationStreamProvider to avoid infinite background timers in unit tests
          locationStreamProvider.overrideWith(
            (ref) => Stream.value(tLocation),
          ),
        ],
        child: const MapKApp(),
      ),
    );

    // Pump to settle UI
    await tester.pumpAndSettle();

    expect(find.text('Map K — Phase 0 Clean Architecture'), findsOneWidget);
    expect(find.text('Single Feature Module: Location'), findsOneWidget);
  });
}
