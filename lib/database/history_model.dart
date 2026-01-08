class DiagnosisHistory {
  final int? id;
  final String imagePath;
  final String diseaseName; // Nama penyakit (Early Blight, Bacterial Spot, dll)
  final String category; // Kategori kondisi (Healthy, Bacterial Infection, dll)
  final double confidence;
  final String recommendation;
  final int colorValue; // Warna kategori
  final DateTime timestamp;

  DiagnosisHistory({
    this.id,
    required this.imagePath,
    required this.diseaseName,
    required this.category,
    required this.confidence,
    required this.recommendation,
    required this.colorValue,
    required this.timestamp,
  });

  // Convert dari Map (dari database) ke Object
  factory DiagnosisHistory.fromMap(Map<String, dynamic> map) {
    return DiagnosisHistory(
      id: map['id'] as int?,
      imagePath: map['imagePath'] as String,
      diseaseName: map['diseaseName'] as String,
      category: map['category'] as String,
      confidence: map['confidence'] as double,
      recommendation: map['recommendation'] as String,
      colorValue: map['colorValue'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  // Convert dari Object ke Map (untuk database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'diseaseName': diseaseName,
      'category': category,
      'confidence': confidence,
      'recommendation': recommendation,
      'colorValue': colorValue,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'DiagnosisHistory{id: $id, diseaseName: $diseaseName, category: $category, confidence: $confidence, timestamp: $timestamp}';
  }
}