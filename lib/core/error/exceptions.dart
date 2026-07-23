/// Base Exceptions for Data layer.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class LocationPermissionException implements Exception {
  final String message;
  const LocationPermissionException({this.message = 'Location permission denied'});

  @override
  String toString() => 'LocationPermissionException: $message';
}

class LocationServiceDisabledException implements Exception {
  final String message;
  const LocationServiceDisabledException({this.message = 'Location service is disabled'});

  @override
  String toString() => 'LocationServiceDisabledException: $message';
}
