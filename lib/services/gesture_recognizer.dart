import 'dart:math';
import '../models/asl_sign.dart';

class GestureRecognizer {
  /// Compares detected landmarks from the camera with expected landmarks of an ASL sign.
  ///
  /// This implements a simplified Cosine Similarity / Normalized Euclidean algorithm
  /// for comparing the relative positions of joints.
  ///
  /// Returns a confidence score between 0.0 and 1.0.
  static double calculateSimilarity(List<HandLandmark> detected, List<HandLandmark> expected) {
    if (detected.isEmpty || expected.isEmpty) return 0.0;

    // Ensure both sets have the same number of dimensions/joints before comparing.
    if (detected.length != expected.length) {
      return 0.0;
    }

    // Step 1: Translate landmarks to be origin-centric (relative to the wrist).
    // This removes translation bias (where the hand is on the screen).
    final originDetected = detected.first; // Assume first is wrist/root
    final originExpected = expected.first;

    List<HandLandmark> normalizedDetected = _normalizeToOrigin(detected, originDetected);
    List<HandLandmark> normalizedExpected = _normalizeToOrigin(expected, originExpected);

    // Step 2: Calculate scale/Euclidean distance.
    // In a robust implementation, you scale the hand bounding box to 1.0 to remove size bias.
    // Here we compute the average Euclidean error across all normalized joints.
    double totalError = 0;
    for (int i = 0; i < normalizedDetected.length; i++) {
       totalError += normalizedDetected[i].distanceTo(normalizedExpected[i]);
    }

    double averageError = totalError / normalizedDetected.length;

    // Step 3: Convert error to a similarity score (inverse relationship).
    // An error of 0 means perfect match (score 1.0).
    // A high threshold error (e.g., > 0.5) implies no match (score 0.0).
    const double maxTolerableError = 0.5;
    double similarity = 1.0 - (averageError / maxTolerableError);

    return similarity.clamp(0.0, 1.0);
  }

  /// Helper to shift all coordinates so that the [origin] becomes (0,0,0).
  static List<HandLandmark> _normalizeToOrigin(List<HandLandmark> landmarks, HandLandmark origin) {
    return landmarks.map((l) => HandLandmark(
      x: l.x - origin.x,
      y: l.y - origin.y,
      z: l.z - origin.z,
    )).toList();
  }
}
