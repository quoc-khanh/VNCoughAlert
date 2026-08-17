import 'package:vncoughalert/features/chat/domain/models/diagnosis_models.dart';

abstract final class DemoDiagnosis {
  static const intakePrompt = '''
**Thông tin cần cung cấp**

Vui lòng gửi **một tin nhắn** kèm **ghi âm tiếng ho** 🎙️ với:

1. **Tuổi của bạn**
2. **Tiền sử bệnh** (hen suyễn, COPD, viêm phế quản, dị ứng…)
3. **Triệu chứng hiện tại** (ho khô/có đờm, sốt, khó thở, tức ngực, mệt mỏi…)
''';

  static const coughPrompt = '''
Cảm ơn bạn. Bấm **micro** và ghi âm tiếng ho trong **5 giây** ở nơi yên tĩnh.
''';

  static const analyzingText = 'Đang phân tích âm thanh và triệu chứng…';

  static const resultIntro = '''
**Kết quả phân tích AI**

*Kết quả chỉ mang tính cảnh báo tham khảo, không thay thế chẩn đoán của bác sĩ.*
''';

  static const caseStudyBody = '''
**Case study (ẩn danh)**

Bệnh nhân nam 44 tuổi, tiền sử hen suyễn, ho có đờm vàng 2 tuần, khó thở nhẹ khi gắng sức. Phổ âm tiếng ho tương tự mẫu của bạn. Chẩn đoán lâm sàng: viêm phế quản cấp, điều trị nội khoa và theo dõi.
''';

  static const connectDoctorMessage = 'Demo: sẽ kết nối cơ sở y tế gần nhất.';

  static const trendMessage = 'Xu hướng triệu chứng — sắp có.';
  static const reportMessage = 'Báo cáo sức khỏe — sắp có.';

  static const mockResults = [
    DiagnosisResult(
      name: 'Viêm phế quản',
      nameEn: 'Bronchitis',
      severity: DiagnosisSeverity.medium,
      confidencePercent: 80,
      summary:
          'Viêm đường hô hấp dưới, thường do virus hoặc vi khuẩn. Triệu chứng thường kéo dài 1–3 tuần.',
      matchedSymptoms: ['Ho có đờm vàng', 'Khó thở nhẹ', 'Tức ngực', 'Sốt nhẹ'],
      recommendations: [
        'Nghỉ ngơi và uống đủ nước ấm.',
        'Tránh khói thuốc và không khí ô nhiễm.',
        'Theo dõi sốt; gặp bác sĩ nếu khó thở tăng hoặc ho kéo dài >3 tuần.',
        'Tham khảo Hướng dẫn chẩn đoán Bộ Y tế / WHO.',
      ],
    ),
    DiagnosisResult(
      name: 'Hen suyễn',
      nameEn: 'Asthma',
      severity: DiagnosisSeverity.medium,
      confidencePercent: 80,
      summary:
          'Bệnh viêm mạn tính đường thở; triệu chứng có thể tái phát khi tiếp xúc yếu tố kích thích.',
      matchedSymptoms: ['Hen suyễn (tiền sử)', 'Khó thở nhẹ', 'Tức ngực'],
      recommendations: [
        'Tránh yếu tố kích thích (bụi, phấn hoa, khói).',
        'Dùng thuốc theo chỉ định bác sĩ nếu đang điều trị hen.',
        'Theo dõi đáp ứng thuốc cắt cơn; tái khám nếu triệu chứng không giảm.',
      ],
    ),
  ];
}
