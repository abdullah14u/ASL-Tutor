import 'dart:math';

class HandLandmark {
  final double x;
  final double y;
  final double z;

  const HandLandmark({required this.x, required this.y, required this.z});

  /// Calculates the Euclidean distance between this landmark and another.
  double distanceTo(HandLandmark other) {
    return sqrt(
      pow(x - other.x, 2) + pow(y - other.y, 2) + pow(z - other.z, 2),
    );
  }
}

class AslSign {
  final String label;
  final String description;
  final List<HandLandmark>
  expectedLandmarks; // Normalized coordinates for comparison

  const AslSign({
    required this.label,
    required this.description,
    required this.expectedLandmarks,
  });
}
