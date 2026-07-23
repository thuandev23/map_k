import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/location_model.dart';

abstract class LocationRemoteDataSource {
  Future<void> sendLocationToServer(LocationModel location);
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final Dio dio;

  LocationRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> sendLocationToServer(LocationModel location) async {
    try {
      // Endpoint placeholder for syncing location
      await dio.post('/api/v1/location', data: location.toJson());
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Lỗi kết nối máy chủ.',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
