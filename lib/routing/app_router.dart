import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/preview/design_preview_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/preview',
  routes: [
    GoRoute(
      path: '/preview',
      name: 'preview',
      builder: (context, state) => const DesignPreviewScreen(),
    ),
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const DesignPreviewScreen(),
    ),
    // Sonraki aşamalarda eklenecek deep-link yolları:
    // /vakitler, /kible, /ayet, /hadis, /ayarlar
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Sayfa bulunamadı: ${state.uri}'),
    ),
  ),
);
