import 'dart:async';
import '../models/location_model.dart';

abstract class LocationLocalDataSource {
  Future<LocationModel> getLastKnownLocation();
  Future<LocationModel> getCurrentLocation();
  Stream<LocationModel> watchLocationStream();
}

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  @override
  Future<LocationModel> getLastKnownLocation() async {
    return LocationModel(
      latitude: 10.776889,
      longitude: 106.700806,
      accuracy: 10.0,
      speed: 0.0,
      heading: 0.0,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<LocationModel> getCurrentLocation() async {
    return LocationModel(
      latitude: 10.776889,
      longitude: 106.700806,
      accuracy: 5.0,
      speed: 1.2,
      heading: 90.0,
      timestamp: DateTime.now(),
    );
  }

  @override
  Stream<LocationModel> watchLocationStream() {
    late final StreamController<LocationModel> controller;
    Timer? timer;
    double lat = 10.776889;
    double lng = 106.700806;

    controller = StreamController<LocationModel>(
      onListen: () {
        timer = Timer.periodic(const Duration(seconds: 2), (_) {
          lat += 0.0001;
          lng += 0.0001;
          if (!controller.isClosed) {
            controller.add(
              LocationModel(
                latitude: lat,
                longitude: lng,
                accuracy: 4.5,
                speed: 2.5,
                heading: 45.0,
                timestamp: DateTime.now(),
              ),
            );
          }
        });
      },
      onCancel: () {
        timer?.cancel();
        controller.close();
      },
    );

    return controller.stream;
  }
}
