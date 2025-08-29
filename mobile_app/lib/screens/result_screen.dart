import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/confidence_bar.dart';

class ResultScreen extends StatelessWidget {
  final String imagePath;
  final Map<String, dynamic> result;

  const ResultScreen({
    super.key,
    required this.imagePath,
    required this.result,
  });

  String _formatDiseaseName(String name) {
    return name.replaceAll('_', ' ').split(' ')
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final double confidence = result['confidence'];
    final String disease = result['label'];

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Result')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.file(File(imagePath), height: 250, fit: BoxFit.cover),
            const SizedBox(height: 20),

            Text(
              _formatDiseaseName(disease),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Text(
              'Confidence: ${confidence.toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 18,
                color: confidence > 70 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 20),

            ConfidenceBar(confidence: confidence / 100),
            const SizedBox(height: 30),

            _buildRecommendationsCard(disease),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(String disease) {
    final Map<String, List<String>> recommendations = {
      "Bacteria": [
        "Используйте сертифицированный семенной материал.",
        "Просушивайте клубни перед хранением.",
        "Дезинфицируйте хранилища и тару.",
        "Контролируйте насекомых-переносчиков.",
        "Избегайте переувлажнения почвы."
      ],
      "Early_blight": [
        "Проводите профилактические обработки фунгицидами.",
        "Используйте контактные и системные препараты (манкоцеб, азоксистробин).",
        "Вносите калийные удобрения для повышения устойчивости.",
        "Уничтожайте растительные остатки."
      ],
      "Fungi": [
        "Протравливайте клубни перед посадкой.",
        "Соблюдайте севооборот, сейте сидераты.",
        "Корректируйте кислотность почвы (при парше).",
        "Сажайте в прогретую почву."
      ],
      "Phytophthora": [
        "Начинайте профилактику ещё до появления признаков.",
        "Применяйте системные фунгициды (Ревус Топ, Орвего).",
        "Используйте медьсодержащие препараты.",
        "Скашивайте ботву за 7–10 дней до уборки.",
        "Выбирайте устойчивые сорта."
      ],
      "Nematode": [
        "Используйте устойчивые сорта.",
        "Соблюдайте строгий севооборот.",
        "Применяйте биопрепараты против нематод.",
        "Соблюдайте карантинные меры."
      ],
      "Virus": [
        "Боритесь с тлёй и другими переносчиками.",
        "Используйте безвирусный посадочный материал.",
        "Удаляйте больные растения.",
        "Не сажайте рядом с паслёновыми сорняками."
      ],
      "Pest": [
        "Против колорадского жука: ручной сбор, инсектициды, биопрепараты.",
        "Против проволочника: приманки, глубокая перекопка, обработка почвы.",
        "Против тли: уничтожение сорняков, инсектициды, привлечение божьих коровок."
      ],
      "Healthy": [
        "Соблюдайте севооборот и используйте сертифицированный материал.",
        "Поддерживайте сбалансированное питание.",
        "Регулярно рыхлите и окучивайте растения.",
        "Избегайте переувлажнения и засухи."
      ]
    };

    final tips = recommendations[disease] ?? ["Нет данных по этому заболеванию"];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Индивидуальные рекомендации",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...tips.map((tip) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 22),
                  const SizedBox(width: 10),
                  Expanded(child: Text(tip, style: const TextStyle(fontSize: 16))),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
