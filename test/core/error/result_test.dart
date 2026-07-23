import 'package:flutter_test/flutter_test.dart';
import 'package:map_k/core/error/failures.dart';
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
  });
}
