import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/tflite_service.dart';
import '../services/database_service.dart';
import '../models/scan_result.dart';
import 'result_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  final TFLiteService _tfliteService = TFLiteService();
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _tfliteService.loadModel();
  }

  @override
  void dispose() {
    _tfliteService.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
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
    return Scaffold(
      appBar: AppBar(title: const Text("Галерея")),
      body: Center(
        child: ElevatedButton(
          onPressed: _pickImage,
          child: const Text("Выбрать фото"),
        ),
      ),
    );
  }
}
