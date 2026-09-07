import 'dart:ui';
import 'dart:isolate';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../models/asl_sign.dart';

/// A message class to pass data to the isolate
class IsolateData {
  final CameraImage image;
  final SendPort sendPort;
  final InputImageRotation rotation;

  IsolateData(this.image, this.sendPort, this.rotation);
}

class IsolateProcessor {
  Isolate? _isolate;
  ReceivePort? _receivePort;
  SendPort? _sendPort;

  Future<void> start() async {
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_entryPoint, _receivePort!.sendPort);

    // Wait for the isolate to send its SendPort back
    _sendPort = await _receivePort!.first as SendPort;
  }

  /// Processes the image in the isolate and returns the detected landmarks
  Future<List<HandLandmark>?> processImage(CameraImage image, int sensorOrientation) async {
    if (_sendPort == null) return null;

    final responsePort = ReceivePort();

    // Convert sensor orientation to ML Kit InputImageRotation
    final rotation = InputImageRotationValue.fromRawValue(sensorOrientation) ?? InputImageRotation.rotation0deg;

    _sendPort!.send(IsolateData(image, responsePort.sendPort, rotation));

    final result = await responsePort.first;
    return result as List<HandLandmark>?;
  }

  void stop() {
    _receivePort?.close();
    _isolate?.kill(priority: Isolate.immediate);
  }

  /// The entry point for the isolate.
  /// This function runs in a separate memory space and processes the vision models
  /// to ensure the main UI thread remains locked at 60 FPS.
  static void _entryPoint(SendPort initialSendPort) async {
    final port = ReceivePort();
    initialSendPort.send(port.sendPort);

    // Initialize the PoseDetector (used as a proxy for hands/joints in this example)
    // In a production app, custom MediaPipe hand tracking models would be loaded here.
    final poseDetector = PoseDetector(options: PoseDetectorOptions());

    port.listen((message) async {
      if (message is IsolateData) {
        try {
          // 1. Convert CameraImage to ML Kit InputImage
          final inputImage = _inputImageFromCameraImage(message.image, message.rotation);
          if (inputImage == null) {
            message.sendPort.send(null);
            return;
          }

          // 2. Run Inference
          final poses = await poseDetector.processImage(inputImage);

          // 3. Extract and normalize landmarks
          List<HandLandmark> landmarks = [];
          if (poses.isNotEmpty) {
            // We use the first detected pose for hand/arm coordinates mapping
            final pose = poses.first;

            // Extracting left/right wrist and index finger as a simplified example
            final wrist = pose.landmarks[PoseLandmarkType.leftWrist];
            final index = pose.landmarks[PoseLandmarkType.leftIndex];

            if (wrist != null && index != null) {
              // Normalize coordinates (0.0 to 1.0) based on image dimensions
              final double width = message.image.width.toDouble();
              final double height = message.image.height.toDouble();

              landmarks.add(HandLandmark(x: wrist.x / width, y: wrist.y / height, z: wrist.z));
              landmarks.add(HandLandmark(x: index.x / width, y: index.y / height, z: index.z));
            }
          }

          // 4. Send processed coordinates back to the main thread
          message.sendPort.send(landmarks.isEmpty ? null : landmarks);

        } catch (e) {
          debugPrint('Isolate processing error: $e');
          message.sendPort.send(null);
        }
      }
    });
  }

  /// Converts a Flutter CameraImage to an ML Kit InputImage
  static InputImage? _inputImageFromCameraImage(CameraImage image, InputImageRotation rotation) {
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    if (image.planes.isEmpty) return null;

    return InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }
}
