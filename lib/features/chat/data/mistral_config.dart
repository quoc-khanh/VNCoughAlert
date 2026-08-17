class MistralChatConfig {
  const MistralChatConfig({
    this.apiKey = const String.fromEnvironment('MISTRAL_API_KEY'),
    this.model = mistralSmall2603,
  });

  static const mistralSmall2603 = 'mistral-small-2603';
  static const maxHistoryMessages = 40;
  static const voicePlaceholder = '[Người dùng gửi ghi âm, chưa có transcript]';
  static const systemPrompt =
      'Bạn là trợ lý chat của VNCoughAlert. Trả lời tiếng Việt, ngắn gọn '
      'và hữu ích. Bạn không chẩn đoán y khoa và không thay thế bác sĩ.';
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
