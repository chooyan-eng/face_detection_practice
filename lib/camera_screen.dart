import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraDescription? _camera;
  CameraController? _controller;
  bool _isDetected = false;
  DateTime? _lastDetected;

  Future<InputImage?> _detectFromCamera(CameraImage image) async {
    final rotation =
        InputImageRotationValue.fromRawValue(_camera!.sensorOrientation)!;

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      return;
    }
    final camera = cameras.first;
    _controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21 // for Android
          : ImageFormatGroup.bgra8888,
    );
    await _controller!.initialize();
    _lastDetected = DateTime.now();
    _controller!.startImageStream((image) async {
      if (DateTime.now().difference(_lastDetected!) <
          const Duration(milliseconds: 500)) {
        return;
      }
      final inputImage = await _detectFromCamera(image);
      if (inputImage == null) {
        return;
      }
      final options = FaceDetectorOptions();
      final faceDetector = FaceDetector(options: options);
      final faces = await faceDetector.processImage(inputImage);
      setState(() => _isDetected = faces.isNotEmpty);
      _lastDetected = DateTime.now();
    });
    setState(() => _camera = camera);
  }

  @override
  Widget build(BuildContext context) {
    return _camera == null
        ? const Text('Preparing Camera')
        : Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                child: CameraPreview(_controller!),
              ),
              const SizedBox(height: 32),
              Text(
                _isDetected ? 'Face Detected' : 'Face NOT Detected',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _isDetected ? Colors.blue : Colors.red,
                ),
              ),
            ],
          );
  }
}
