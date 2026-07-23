/// Base Failure class for domain layer error representation.
/// Pure Dart - No Flutter imports allowed.
sealed class Failure {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          statusCode == other.statusCode;

  @override
  int get hashCode => message.hashCode ^ statusCode.hashCode;

  @override
  String toString() => '$runtimeType(message: $message, statusCode: $statusCode)';
}

final class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

final class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.statusCode});
}

final class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Không có kết nối mạng. Vui lòng kiểm tra lại.',
    super.statusCode,
  });
}

final class LocationPermissionFailure extends Failure {
  const LocationPermissionFailure({
    super.message = 'Quyền truy cập vị trí bị từ chối.',
    super.statusCode,
  });
}

final class LocationServiceDisabledFailure extends Failure {
  const LocationServiceDisabledFailure({
    super.message = 'Dịch vụ vị trí (GPS) đang bị tắt.',
    super.statusCode,
  });
}

final class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Đã có lỗi không xác định xảy ra.',
    super.statusCode,
  });
}
