import '../error/failures.dart';
import '../error/result.dart';

/// Base abstract class for all UseCases returning a Future.
/// Pure Dart - No Flutter imports allowed.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Base abstract class for UseCases returning a Stream.
/// Pure Dart - No Flutter imports allowed.
abstract class StreamUseCase<T, Params> {
  Stream<Either<Failure, T>> call(Params params);
}

/// Class to represent no parameters for UseCases.
class NoParams {
  const NoParams();
}
