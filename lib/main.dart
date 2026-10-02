import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/env_config.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/widgets_bridge/home_widget_service.dart';
import 'routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Türkçe tarih biçimlendirme başlangıç kurulumu (Kritik kural)
  await initializeDateFormatting('tr_TR', null);

  // Ortam değişkenlerini (.env) güvenli bir şekilde yükle (offline fallback destekli)
  await EnvConfig.init();

  // Supabase Başlatma (Güvenli anon erişim, offline mod destekli)
  if (EnvConfig.hasSupabaseConfig) {
    try {
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        publishableKey: EnvConfig.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Supabase başlatılamadı ($e). Çevrimdışı modda devam ediliyor.');
    }
  }

  // Ana ekran widget köprüsünü başlat
  await HomeWidgetService.initialize();

  runApp(
    const ProviderScope(
      child: VakitApp(),
    ),
  );
}

class VakitApp extends ConsumerWidget {
  const VakitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Vakit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [
        Locale('tr', 'TR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
