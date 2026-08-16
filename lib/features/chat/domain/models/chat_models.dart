enum ChatRole { user, assistant }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.isPending = false,
  });

  final String id;
  final ChatRole role;
  final String text;
  final DateTime createdAt;
  final bool isPending;

  ChatMessage copyWith({String? text, bool? isPending}) {
    return ChatMessage(
      id: id,
      role: role,
      text: text ?? this.text,
      createdAt: createdAt,
      isPending: isPending ?? this.isPending,
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
