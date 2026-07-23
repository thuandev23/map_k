import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/error/exceptions.dart';
import '../models/location_model.dart';

abstract class LocationLocalDataSource {
  Future<LocationModel> getLastKnownLocation();
  Future<LocationModel> getCurrentLocation();
  Stream<LocationModel> watchLocationStream();
}

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  static const _channel = MethodChannel('com.mapk/location');

  @override
  Future<LocationModel> getLastKnownLocation() async {
    return getCurrentLocation();
  }

  @override
  Future<LocationModel> getCurrentLocation() async {
    PermissionStatus status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
    }

    if (status.isGranted || status.isLimited) {
      try {
        final result = await _channel.invokeMethod<Map>('getCurrentLocation');
        if (result != null) {
          final lat = (result['lat'] as num).toDouble();
          final lng = (result['lng'] as num).toDouble();
          return LocationModel(
            latitude: lat,
            longitude: lng,
            accuracy: 5.0,
            speed: 0.0,
            heading: 0.0,
            timestamp: DateTime.now(),
          );
        } else {
          // Default fallback location if hardware location is null
          return LocationModel(
            latitude: 10.776889,
            longitude: 106.700806,
            accuracy: 10.0,
            speed: 0.0,
            heading: 0.0,
            timestamp: DateTime.now(),
          );
        }
      } on PlatformException catch (e) {
        if (e.code == 'NO_LOCATION') {
          // Default fallback location for Simulator without active simulated location
          return LocationModel(
            latitude: 10.776889,
            longitude: 106.700806,
            accuracy: 10.0,
            speed: 0.0,
            heading: 0.0,
            timestamp: DateTime.now(),
          );
        }
        throw LocationServiceDisabledException(
            message: e.message ?? 'Lỗi dịch vụ vị trí Platform Channel.');
      }
    } else {
      throw const LocationPermissionException(
          message: 'Quyền truy cập vị trí bị từ chối. Vui lòng cho phép quyền vị trí trong Cài đặt.');
    }
  }

  @override
  Stream<LocationModel> watchLocationStream() {
    late final StreamController<LocationModel> controller;
    Timer? timer;

    controller = StreamController<LocationModel>(
      onListen: () {
        timer = Timer.periodic(const Duration(seconds: 3), (_) async {
          try {
            final model = await getCurrentLocation();
            if (!controller.isClosed) {
              controller.add(model);
            }
          } catch (e) {
            // Ignore error in stream polling
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
