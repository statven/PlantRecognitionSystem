class ScanResult {
  final int? id;
  final String imagePath;
  final String diseaseName;
  final double confidence;
  final int timestamp;

  ScanResult({
    this.id,
    required this.imagePath,
    required this.diseaseName,
    required this.confidence,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'diseaseName': diseaseName,
      'confidence': confidence,
      'timestamp': timestamp,
    };
  }

  factory ScanResult.fromMap(Map<String, dynamic> map) {
    return ScanResult(
      id: map['id'],
      imagePath: map['imagePath'],
      diseaseName: map['diseaseName'],
      confidence: map['confidence'],
      timestamp: map['timestamp'],
    );
  }
}
