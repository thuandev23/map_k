import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/datasources/location_local_data_source.dart';
import '../../data/datasources/location_remote_data_source.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/watch_location_stream.dart';

// --- Data Sources & Repository DI Providers ---

final locationLocalDataSourceProvider = Provider<LocationLocalDataSource>((ref) {
  return LocationLocalDataSourceImpl();
});

final locationRemoteDataSourceProvider = Provider<LocationRemoteDataSource>((ref) {
  return LocationRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl(
    local: ref.watch(locationLocalDataSourceProvider),
    remote: ref.watch(locationRemoteDataSourceProvider),
  );
});

// --- UseCase Providers ---

final getCurrentLocationUseCaseProvider = Provider<GetCurrentLocation>((ref) {
  return GetCurrentLocation(ref.watch(locationRepositoryProvider));
});

final watchLocationStreamUseCaseProvider = Provider<WatchLocationStream>((ref) {
  return WatchLocationStream(ref.watch(locationRepositoryProvider));
});

// --- Location Controller State & AsyncNotifier ---

class LocationController extends StateNotifier<AsyncValue<LocationEntity>> {
  final GetCurrentLocation _getCurrentLocation;

  LocationController(this._getCurrentLocation)
      : super(const AsyncValue.loading()) {
    fetchCurrentLocation();
  }

  Future<void> fetchCurrentLocation() async {
    state = const AsyncValue.loading();
    final result = await _getCurrentLocation(const NoParams());
    result.fold(
      onLeft: (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      onRight: (location) {
        state = AsyncValue.data(location);
      },
    );
  }
}

final locationControllerProvider =
    StateNotifierProvider<LocationController, AsyncValue<LocationEntity>>((ref) {
  return LocationController(ref.watch(getCurrentLocationUseCaseProvider));
});

final locationStreamProvider = StreamProvider<LocationEntity>((ref) async* {
  final useCase = ref.watch(watchLocationStreamUseCaseProvider);
  await for (final result in useCase(const NoParams())) {
    if (result.isRight) {
      yield result.rightOrNull!;
    }
  }
});
