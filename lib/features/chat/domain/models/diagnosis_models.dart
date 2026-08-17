enum DiagnosisSeverity { low, medium, high }

class DiagnosisResult {
  const DiagnosisResult({
    required this.name,
    required this.nameEn,
    required this.severity,
    required this.confidencePercent,
    required this.summary,
    required this.matchedSymptoms,
    required this.recommendations,
  });

  final String name;
  final String nameEn;
  final DiagnosisSeverity severity;
  final int confidencePercent;
  final String summary;
  final List<String> matchedSymptoms;
  final List<String> recommendations;

  String get severityLabel => switch (severity) {
    DiagnosisSeverity.low => 'Thấp',
    DiagnosisSeverity.medium => 'Trung bình',
    DiagnosisSeverity.high => 'Cao',
  };
}
