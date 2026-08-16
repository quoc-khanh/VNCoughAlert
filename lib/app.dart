import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vncoughalert/design_system/theme/app_theme.dart';
import 'package:vncoughalert/router/app_coordinator.dart';

class VnCoughAlertApp extends StatelessWidget {
  const VnCoughAlertApp({super.key, required this.coordinator});

  final AppCoordinator coordinator;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VNCoughAlert',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: coordinator,
    );
  }
}

class VnCoughAlertRoot extends StatelessWidget {
  const VnCoughAlertRoot({super.key, required this.coordinator});

  final AppCoordinator coordinator;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(child: VnCoughAlertApp(coordinator: coordinator));
  }
}
