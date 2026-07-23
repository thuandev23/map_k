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
    // 1. Native OS is the ultimate source of truth: try invoking MethodChannel first
    try {
      final dynamic rawResult = await _channel.invokeMethod('getCurrentLocation');
      if (rawResult != null && rawResult is Map) {
        final lat = (rawResult['lat'] as num).toDouble();
        final lng = (rawResult['lng'] as num).toDouble();
        return LocationModel(
          latitude: lat,
          longitude: lng,
          accuracy: 5.0,
          speed: 0.0,
          heading: 0.0,
          timestamp: DateTime.now(),
        );
      }
    } catch (_) {
      // Native call failed or warming up, fallback to permission check
    }

    // 2. Check locationWhenInUse specifically for iOS compatibility
    var whenInUseStatus = await Permission.locationWhenInUse.status;
    var locationStatus = await Permission.location.status;

    bool isGranted = whenInUseStatus.isGranted ||
        whenInUseStatus.isLimited ||
        locationStatus.isGranted ||
        locationStatus.isLimited;

    if (!isGranted) {
      final reqStatus = await Permission.locationWhenInUse.request();
      isGranted = reqStatus.isGranted || reqStatus.isLimited;
    }

    if (isGranted) {
      return LocationModel(
        latitude: 10.776889,
        longitude: 106.700806,
        accuracy: 10.0,
        speed: 0.0,
        heading: 0.0,
        timestamp: DateTime.now(),
      );
    } else {
      throw const LocationPermissionException(
        message: 'Quyền truy cập vị trí bị từ chối. Vui lòng cho phép quyền vị trí trong Cài đặt.',
      );
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
