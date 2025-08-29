import 'package:flutter/material.dart';

class ConfidenceBar extends StatelessWidget {
  final double confidence;

  const ConfidenceBar({super.key, required this.confidence});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Confidence Level:'),
        const SizedBox(height: 5),
        Container(
          height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[300],
          ),
          child: FractionallySizedBox(
            widthFactor: confidence,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: _getConfidenceColor(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getConfidenceColor() {
    if (confidence > 0.8) return Colors.green;
    if (confidence > 0.6) return Colors.lightGreen;
    if (confidence > 0.4) return Colors.orange;
    return Colors.red;
  }
}