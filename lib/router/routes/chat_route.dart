import 'package:flutter/material.dart';
import 'package:vncoughalert/features/chat/presentation/chat_page.dart';
import 'package:vncoughalert/router/app_coordinator.dart';
import 'package:vncoughalert/router/app_route.dart';

class ChatRoute extends AppRoute {
  ChatRoute({this.chatId});

  final String? chatId;

  @override
  List<Object?> get props => [chatId];

  @override
  Uri toUri() {
    final id = chatId;
    if (id == null || id.isEmpty) {
      return Uri.parse('/');
    }
    return Uri.parse('/chat/$id');
  }

  @override
  Widget build(covariant AppCoordinator coordinator, BuildContext context) {
    final currentId = chatId;
    return ChatPage(
      chatId: currentId,
      onNewChat: () {
        coordinator.replace(ChatRoute());
      },
      onOpenChat: (id) {
        if (currentId == null || currentId.isEmpty) {
          coordinator.replace(ChatRoute(chatId: id));
          return;
        }
        if (currentId != id) {
          coordinator.push(ChatRoute(chatId: id));
        }
      },
    );
  }
}
