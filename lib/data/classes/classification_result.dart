class ClassificationResult {
  final String label;
  final double confidence;

  const ClassificationResult({
    required this.label,
    required this.confidence,
  });

  String get confidencePercent => "${(confidence * 100).toStringAsFixed(1)}%";
}
