import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  CameraController? get controller => _controller;

  Future<void> initialize(Function(CameraImage) onImage) async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        debugPrint('No cameras found.');
        return;
      }

      // Select the front camera for ASL recognition
      final frontCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: kIsWeb
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();

      // Start streaming images
      _controller!.startImageStream(onImage);
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
  }
}
