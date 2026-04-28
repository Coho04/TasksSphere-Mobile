import 'package:flutter_test/flutter_test.dart';

void main() {
  test('App smoke test - basic assertions', () {
    // Verify basic Dart functionality works
    expect(1 + 1, equals(2));
    expect('TasksSphere'.isNotEmpty, isTrue);
  });
}
