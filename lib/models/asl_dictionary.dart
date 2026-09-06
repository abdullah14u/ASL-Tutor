import 'asl_sign.dart';

class AslDictionary {
  /// Defines a dictionary of ASL signs and their skeletal coordinate mappings.
  ///
  /// In a real-world application, these coordinates would be derived from an extensive
  /// dataset of 3D hand tracking landmarks. For this prototype, we mock the expected
  /// landmarks to represent basic poses (e.g., all fingers closed for 'A', index finger
  /// up for '1').

  static final List<AslSign> signs = [
    const AslSign(
      label: 'A',
      description: 'Fist with thumb resting on the side of the index finger.',
      expectedLandmarks: [
        // Mocked 21 landmarks for 'A' (fist)
        HandLandmark(x: 0.5, y: 0.8, z: 0.0), // Wrist
        // ... (remaining landmarks would be populated here)
      ],
    ),
    const AslSign(
      label: 'B',
      description:
          'Hand flat, fingers together and pointing up, thumb folded across palm.',
      expectedLandmarks: [
        // Mocked landmarks for 'B'
        HandLandmark(x: 0.5, y: 0.8, z: 0.0),
      ],
    ),
    const AslSign(
      label: 'C',
      description: 'Fingers and thumb curved to form a "C" shape.',
      expectedLandmarks: [
        // Mocked landmarks for 'C'
        HandLandmark(x: 0.5, y: 0.8, z: 0.0),
      ],
    ),
  ];

  static AslSign? getSignByLabel(String label) {
    try {
      return signs.firstWhere((sign) => sign.label == label);
    } catch (e) {
      return null;
    }
  }
}
