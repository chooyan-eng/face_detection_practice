import 'package:face_detection_practice/camera_screen.dart';
import 'package:face_detection_practice/detect_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _isPicker = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 32),
              CupertinoSegmentedControl<int>(
                children: const {
                  0: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Photo'),
                  ),
                  1: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Camera'),
                  ),
                },
                onValueChanged: (int value) {
                  setState(() {
                    _isPicker = value == 0;
                  });
                },
                groupValue: _isPicker ? 0 : 1,
              ),
              const SizedBox(height: 32),
              _isPicker ? const DetectScreen() : const CameraScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
