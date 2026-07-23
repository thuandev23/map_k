import 'package:flutter_test/flutter_test.dart';
import 'package:map_k/core/error/exceptions.dart';
import 'package:map_k/core/error/failures.dart';
import 'package:map_k/core/error/guard.dart';
import 'package:map_k/core/error/result.dart';

void main() {
  group('Custom Either/Result Unit Tests', () {
    test('Right should represent success value', () {
      const Either<Failure, String> result = Right('Success Data');

      expect(result.isRight, true);
      expect(result.isLeft, false);
      expect(result.rightOrNull, 'Success Data');
      expect(result.leftOrNull, isNull);

      final folded = result.fold(
        onLeft: (f) => 'Failed',
        onRight: (data) => data,
      );
      expect(folded, 'Success Data');
    });

    test('Left should represent failure value', () {
      const failure = ServerFailure(message: 'Server error', statusCode: 500);
      const Either<Failure, String> result = Left(failure);

      expect(result.isLeft, true);
      expect(result.isRight, false);
      expect(result.leftOrNull, failure);
      expect(result.rightOrNull, isNull);

      final folded = result.fold(
        onLeft: (f) => f.message,
        onRight: (data) => 'Success',
      );
      expect(folded, 'Server error');
    });

    test('map should transform Right value and leave Left untouched', () {
      const Either<Failure, int> rightVal = Right(10);
      final mappedRight = rightVal.map((r) => r * 2);
      expect(mappedRight, const Right<Failure, int>(20));

      const failure = ServerFailure(message: 'Error');
      const Either<Failure, int> leftVal = Left(failure);
      final mappedLeft = leftVal.map((r) => r * 2);
      expect(mappedLeft, const Left<Failure, int>(failure));
    });

    test('flatMap should chain Either transformations', () {
      const Either<Failure, int> rightVal = Right(10);
      final flatMappedRight =
          rightVal.flatMap((r) => Right<Failure, String>('Value: $r'));
      expect(flatMappedRight, const Right<Failure, String>('Value: 10'));

      const failure = ServerFailure(message: 'Error');
      const Either<Failure, int> leftVal = Left(failure);
      final flatMappedLeft =
          leftVal.flatMap((r) => Right<Failure, String>('Value: $r'));
      expect(flatMappedLeft, const Left<Failure, String>(failure));
    });

    test('guard helper should catch Exception and map to Failure', () async {
      final successResult = await guard(() async => 'Hello');
      expect(successResult, const Right<Failure, String>('Hello'));

      final serverErrorResult = await guard<String>(() async {
        throw const ServerException(message: 'Server Exception', statusCode: 500);
      });
      expect(serverErrorResult.isLeft, true);
      expect(serverErrorResult.leftOrNull, isA<ServerFailure>());
      expect(serverErrorResult.leftOrNull?.message, 'Server Exception');

      final permErrorResult = await guard<String>(() async {
        throw const LocationPermissionException(message: 'Denied');
      });
      expect(permErrorResult.isLeft, true);
      expect(permErrorResult.leftOrNull, isA<LocationPermissionFailure>());
    });
  });
}
