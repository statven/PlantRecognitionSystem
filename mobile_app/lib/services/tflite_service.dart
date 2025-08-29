import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  static final TFLiteService _instance = TFLiteService._internal();
  factory TFLiteService() => _instance;
  TFLiteService._internal();

  Interpreter? _interpreter;
  List<String> _labels = [];

  /// Загружаем модель и метки
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model_quant.tflite');

      final rawLabels = await rootBundle.loadString('assets/labels.txt');
      _labels = rawLabels
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      print("✅ Модель и метки успешно загружены. Количество меток: ${_labels.length}");
    } catch (e) {
      print("❌ Ошибка загрузки модели: $e");
    }
  }

  bool get isLoaded => _interpreter != null;

  /// Softmax
  List<double> _softmax(List<double> logits) {
    final expValues = logits.map((e) => math.exp(e)).toList();
    final sum = expValues.reduce((a, b) => a + b);
    return expValues.map((e) => e / sum).toList();
  }

  /// Классификация изображения
  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    if (_interpreter == null) {
      print("❌ Модель не загружена");
      return {'label': 'Unknown', 'confidence': 0.0};
    }

    final rawImage = img.decodeImage(await imageFile.readAsBytes());
    if (rawImage == null) {
      return {'label': 'Unknown', 'confidence': 0.0};
    }

    // Размер входа модели (например, [1, 224, 224, 3])
    final inputShape = _interpreter!.getInputTensor(0).shape;
    final height = inputShape[1];
    final width = inputShape[2];

    // Ресайз
    final resized = img.copyResize(rawImage, width: width, height: height);

    // Готовим uint8 input
    final input = List.generate(
        1,
        (_) => List.generate(height, (y) =>
            List.generate(width, (x) {
              final pixel = resized.getPixel(x, y);
              final r = img.getRed(pixel);
              final g = img.getGreen(pixel);
              final b = img.getBlue(pixel);
              return [r, g, b]; // uint8
            })));

    // Создаём выход (uint8)
    final outputShape = _interpreter!.getOutputTensor(0).shape;
    final output = List.generate(1, (_) => List.filled(outputShape[1], 0));

    // Инференс
    _interpreter!.run(input, output);

    // Переводим в float
    List<int> rawOutput = output[0].cast<int>();
    final probs = rawOutput.map((v) => (v - 128) / 128.0).toList();

    // Нормализуем через softmax
    final softmaxed = _softmax(probs);

    // Находим лучший класс
    final maxIndex = softmaxed.indexWhere((p) => p == softmaxed.reduce(math.max));
    final confidence = softmaxed[maxIndex] * 200;
    final label = (maxIndex < _labels.length) ? _labels[maxIndex] : "Unknown";

    return {
      'label': label,
      'confidence': confidence,
    };
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
