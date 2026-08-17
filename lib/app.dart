import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
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
  const VnCoughAlertRoot({
    super.key,
    required this.coordinator,
    this.overrides = const [],
  });

  final AppCoordinator coordinator;
  final List<Override> overrides;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: VnCoughAlertApp(coordinator: coordinator),
    );
  }
}
