import 'package:vncoughalert/features/chat/domain/models/diagnosis_models.dart';

enum ChatRole { user, assistant }

class ChatAudio {
  const ChatAudio({
    required this.path,
    required this.duration,
    this.levels = const [],
  });

  final String path;
  final Duration duration;
  final List<double> levels;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.isPending = false,
    this.audios = const [],
    this.diagnoses = const [],
  });

  final String id;
  final ChatRole role;
  final String text;
  final DateTime createdAt;
  final bool isPending;
  final List<ChatAudio> audios;
  final List<DiagnosisResult> diagnoses;

  ChatMessage copyWith({
    String? text,
    bool? isPending,
    List<DiagnosisResult>? diagnoses,
  }) {
    return ChatMessage(
      id: id,
      role: role,
      text: text ?? this.text,
      createdAt: createdAt,
      isPending: isPending ?? this.isPending,
      audios: audios,
      diagnoses: diagnoses ?? this.diagnoses,
    );
  }
}

class ChatSession {
  const ChatSession({
    required this.id,
    required this.title,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final DateTime updatedAt;

  ChatSession copyWith({String? title, DateTime? updatedAt}) {
    return ChatSession(
      id: id,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
