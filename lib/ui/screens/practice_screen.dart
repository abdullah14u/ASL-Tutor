import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_state.dart';
import '../../services/camera_service.dart';
import '../../services/isolate_processor.dart';
import '../../services/gesture_recognizer.dart';
import '../../models/asl_dictionary.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  final CameraService _cameraService = CameraService();
  final IsolateProcessor _isolateProcessor = IsolateProcessor();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _isolateProcessor.start();
    await _cameraService.initialize(_processCameraImage);
    if (mounted) setState(() {});
  }

  void _processCameraImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    // We pass the sensor orientation to ensure the vision model correctly rotates the bounding boxes.
    final sensorOrientation = _cameraService.controller?.description.sensorOrientation ?? 0;
    final landmarks = await _isolateProcessor.processImage(image, sensorOrientation);

    if (landmarks != null && mounted) {
      final currentSignIndex = ref.read(currentSignIndexProvider);
      final expectedSign =
          AslDictionary.signs[currentSignIndex % AslDictionary.signs.length];

      final similarity = GestureRecognizer.calculateSimilarity(
        landmarks,
        expectedSign.expectedLandmarks,
      );

      if (similarity > 0.8) {
        ref.read(isSignCorrectProvider.notifier).setCorrect(true);
        ref.read(streakCountProvider.notifier).increment();
      } else {
        ref.read(isSignCorrectProvider.notifier).setCorrect(false);
        // Reset streak on incorrect sign
        ref.read(streakCountProvider.notifier).reset();
      }
    }

    _isProcessing = false;
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _isolateProcessor.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraService.controller == null ||
        !_cameraService.controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentSignIndex = ref.watch(currentSignIndexProvider);
    final targetSign =
        AslDictionary.signs[currentSignIndex % AslDictionary.signs.length];
    final isCorrect = ref.watch(isSignCorrectProvider);
    final streak = ref.watch(streakCountProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Practice: ${targetSign.label}',
          style: const TextStyle(
            color: Colors.white,
            shadows: [Shadow(blurRadius: 10, color: Colors.black)],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  '$streak',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: 1 / _cameraService.controller!.value.aspectRatio,
              child: CameraPreview(_cameraService.controller!),
            ),
          ),

          // Gamification: Glowing Edge Overlay
          IgnorePointer(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isCorrect
                      ? Colors.green.withOpacity(0.8)
                      : Colors.red.withOpacity(0.3),
                  width: isCorrect ? 10.0 : 4.0,
                ),
              ),
            ),
          ),

          // Gamification: Celebratory Mastery Animation
          if (isCorrect)
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.5, end: 1.2),
                duration: const Duration(milliseconds: 500),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: (1.2 - scale).clamp(0.0, 1.0),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 120,
                      ),
                    ),
                  );
                },
              ),
            ),

          // Overlay instructions
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sign: ${targetSign.label}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    targetSign.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
