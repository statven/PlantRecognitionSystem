import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/tflite_service.dart';
import '../services/database_service.dart';
import '../models/scan_result.dart';
import 'result_screen.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  final TFLiteService _tfliteService = TFLiteService();
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _controller!.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
    _tfliteService.loadModel();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _tfliteService.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) return;

    final image = await _controller!.takePicture();
    final file = File(image.path);

    final result = await _tfliteService.classifyImage(file);

    // сохраняем в SQLite
    final scan = ScanResult(
      imagePath: file.path,
      diseaseName: result['label'],
      confidence: result['confidence'],
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    await _dbService.insertScan(scan);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          imagePath: file.path,
          result: result,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: CameraPreview(_controller!),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
