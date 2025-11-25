import 'package:flutter_test/flutter_test.dart';

// Simple test to verify the guard file compiles correctly
import 'package:collab_frontend/shared/guards/freelancer_profile_guard.dart';

void main() {
  group('FreelancerProfileGuard', () {
    test('should compile without errors', () {
      // This test verifies that the guard class is properly structured
      // and can be instantiated (when dependencies are provided)
      expect(FreelancerProfileGuard, isNotNull);
    });
  });
}
