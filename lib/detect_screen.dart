import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

class DetectScreen extends StatefulWidget {
  const DetectScreen({super.key});

  @override
  State<DetectScreen> createState() => _DetectScreenState();
}

class _DetectScreenState extends State<DetectScreen> {
  Uint8List? _data;
  bool? _isDetected;

  @override
  void initState() {
    super.initState();
    ImagePicker().pickImage(source: ImageSource.gallery).then((image) {
      if (image != null) {
        setState(() {
          _data = File(image.path).readAsBytesSync();
        });
        _detectFromFile(File(image.path)).then((value) {
          setState(() => _isDetected = value);
        });
      }
    });
  }

  Future<bool> _detectFromFile(File file) async {
    final inputImage = InputImage.fromFile(file);
    final options = FaceDetectorOptions();
    final faceDetector = FaceDetector(options: options);
    final faces = await faceDetector.processImage(inputImage);
    return faces.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_data != null)
          AspectRatio(aspectRatio: 1, child: Image.memory(_data!)),
        const SizedBox(height: 32),
        if (_isDetected == null)
          const Center(child: CircularProgressIndicator()),
        if (_isDetected == true)
          const Text(
            'Face Detected',
            style: TextStyle(
              fontSize: 24,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (_isDetected == false)
          const Text(
            'Face NOT Detected',
            style: TextStyle(
              fontSize: 24,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
