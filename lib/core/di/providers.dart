import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/dio_client.dart';

/// Core DioClient Provider
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

/// Raw Dio Instance Provider
final dioProvider = Provider<Dio>((ref) {
  return ref.watch(dioClientProvider).instance;
});
