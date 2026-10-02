import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/widgets/main_scaffold_shell.dart';
import '../features/daily_content/presentation/screens/daily_hadith_screen.dart';
import '../features/daily_content/presentation/screens/daily_verse_screen.dart';
import '../features/prayer_times/presentation/screens/prayer_times_screen.dart';
import '../features/preview/design_preview_screen.dart';
import '../features/qibla/presentation/screens/qibla_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/vakitler',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainScaffoldShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/vakitler',
          name: 'prayer_times',
          builder: (context, state) => const PrayerTimesScreen(),
        ),
        GoRoute(
          path: '/kible',
          name: 'qibla',
          builder: (context, state) => const QiblaScreen(),
        ),
        GoRoute(
          path: '/ayet',
          name: 'verse',
          builder: (context, state) => const DailyVerseScreen(),
        ),
        GoRoute(
          path: '/hadis',
          name: 'hadith',
          builder: (context, state) => const DailyHadithScreen(),
        ),
        GoRoute(
          path: '/ayarlar',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/preview',
      name: 'preview',
      builder: (context, state) => const DesignPreviewScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Sayfa bulunamadı: ${state.uri}'),
    ),
  ),
);
