import 'package:flutter/material.dart';
import 'package:vncoughalert/app.dart';
import 'package:vncoughalert/router/app_coordinator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final coordinator = AppCoordinator();
  runApp(VnCoughAlertRoot(coordinator: coordinator));
}
