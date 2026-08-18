class MistralChatConfig {
  const MistralChatConfig({
    this.apiKey = const String.fromEnvironment('MISTRAL_API_KEY'),
    this.model = mistralSmall2603,
  });

  static const mistralSmall2603 = 'mistral-small-2603';
  static const maxHistoryMessages = 40;
  static const voicePlaceholder = '[Người dùng gửi ghi âm, chưa có transcript]';
  static const systemPrompt =
      'Bạn là trợ lý AI của VNCoughAlert, một ứng dụng cảnh báo sức khỏe hô hấp. '
      'Luôn trả lời bằng tiếng Việt, rõ ràng, ngắn gọn và đồng cảm. '
      'Trong lần đầu người dùng mô tả vấn đề, hãy lần lượt thu thập: tuổi, '
      'tiền sử bệnh và triệu chứng hiện tại. Khi người dùng gửi bản ghi âm, '
      'xác nhận đó là mẫu tiếng ho và hỏi thêm thông tin còn thiếu; không được '
      'khẳng định bạn đã chẩn đoán từ âm thanh nếu chưa có mô hình âm thanh được '
      'kết nối. Nếu đủ dữ liệu, trình bày theo các mục: cảnh báo tham khảo, '
      'độ chắc chắn (chỉ khi có cơ sở), triệu chứng phù hợp, khuyến nghị an toàn, '
      'dấu hiệu cần cấp cứu và nguồn tham khảo như Bộ Y tế hoặc WHO. '
      'Không kê đơn, không thay thế bác sĩ, và luôn nhắc người dùng đi khám khi '
      'có khó thở tăng, đau ngực, tím tái, lơ mơ hoặc ho ra máu.';
  static const screeningPrompt =
      'Tôi muốn bắt đầu quy trình sàng lọc hô hấp của VNCoughAlert. '
      'Hãy hướng dẫn tôi cung cấp tuổi, tiền sử bệnh và triệu chứng hiện tại; '
      'sau đó hướng dẫn ghi âm tiếng ho 5 giây ở nơi yên tĩnh. Hãy giải thích '
      'rõ đây chỉ là cảnh báo tham khảo và không thay thế bác sĩ.';
  static const missingApiKeyMessage =
      'Thiếu MISTRAL_API_KEY. Chạy app với '
      '--dart-define=MISTRAL_API_KEY=...';
  static const emptyReplyMessage = 'Không nhận được phản hồi từ mô hình.';
  static const requestFailedMessage =
      'Không gọi được Mistral. Kiểm tra mạng và API key rồi thử lại.';

  final String apiKey;
  final String model;

  bool get hasApiKey => apiKey.isNotEmpty;
}
