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
    final status = await Permission.location.request();
    if (status.isGranted) {
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
          throw const LocationServiceDisabledException(
              message: 'Vị trí không khả dụng từ thiết bị.');
        }
      } on PlatformException catch (e) {
        throw LocationServiceDisabledException(
            message: e.message ?? 'Lỗi dịch vụ vị trí Platform Channel.');
      }
    } else {
      throw const LocationPermissionException(
          message: 'Quyền truy cập vị trí bị từ chối.');
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
            // Ignore error or emit if needed
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
