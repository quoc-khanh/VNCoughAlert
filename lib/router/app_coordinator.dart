import 'dart:async';

import 'package:vncoughalert/router/app_route.dart';
import 'package:vncoughalert/router/routes/chat_route.dart';
import 'package:zenrouter/zenrouter.dart';

class AppCoordinator extends Coordinator<AppRoute> {
  AppCoordinator();

  @override
  FutureOr<AppRoute> parseRouteFromUri(Uri uri) {
    return switch (uri.pathSegments) {
      [] => ChatRoute(),
      ['chat'] => ChatRoute(),
      ['chat', final id] => ChatRoute(chatId: id),
      _ => ChatRoute(),
    };
  }
}
